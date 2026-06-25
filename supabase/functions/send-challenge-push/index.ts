import { create, getNumericDate } from "https://deno.land/x/djwt@v2.8/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.48.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
  type?: string;
};

type SendResult = { ok: boolean; invalidToken: boolean; error?: string };

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    if (!supabaseUrl || !serviceKey) {
      return new Response(JSON.stringify({ error: "Missing Supabase secrets" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const serviceAccount = loadServiceAccount();
    if (!serviceAccount) {
      return new Response(
        JSON.stringify({
          error:
            "Set FCM_SERVICE_ACCOUNT_JSON (Firebase Admin SDK JSON for HTTP v1). Legacy FCM_SERVER_KEY is deprecated and disabled in Firebase Console.",
          hint:
            "Firebase Console -> Project Settings -> Service accounts -> Generate new private key. Paste full JSON into Supabase Edge Function secret FCM_SERVICE_ACCOUNT_JSON.",
        }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const body = await req.json();
    const userId = String(body.userId ?? "");
    const tokenOverride = String(body.token ?? "");
    const title = String(body.title ?? "Your challenge update");
    const message = String(body.body ?? "Open app to continue your beauty challenge.");
    const data = stringifyData((body.data ?? {}) as Record<string, unknown>);
    if (!userId && !tokenOverride) {
      return new Response(JSON.stringify({ error: "Missing userId" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const admin = createClient(supabaseUrl, serviceKey);
    let all: string[] = [];
    if (tokenOverride) {
      all = [tokenOverride];
    } else {
      const { data: tokens, error } = await admin
        .from("device_push_tokens")
        .select("fcm_token")
        .eq("user_id", userId)
        .eq("is_active", true);
      if (error) throw error;
      all = (tokens ?? []).map((t) => t.fcm_token as string).filter(Boolean);
    }

    const errors: string[] = [];
    if (all.length === 0) {
      errors.push(
        tokenOverride
          ? "No token provided"
          : `No active FCM tokens in device_push_tokens for user ${userId}. Sign in on device and allow notifications.`,
      );
    }

    let sent = 0;
    for (const token of all) {
      const result = await sendFcmV1(serviceAccount, token, title, message, data);
      if (result.ok) {
        sent++;
      } else {
        if (result.error) errors.push(result.error);
        if (result.invalidToken) {
          await admin.from("device_push_tokens").update({ is_active: false }).eq(
            "fcm_token",
            token,
          );
        }
      }
    }

    return new Response(
      JSON.stringify({
        sent,
        total: all.length,
        mode: "fcm_v1",
        projectId: serviceAccount.project_id,
        errors: errors.slice(0, 5),
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

function stringifyData(data: Record<string, unknown>): Record<string, string> {
  const out: Record<string, string> = {};
  for (const [key, value] of Object.entries(data)) {
    out[key] = value == null ? "" : String(value);
  }
  return out;
}

function loadServiceAccount(): ServiceAccount | null {
  const raw = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON")?.trim() ?? "";
  if (!raw || !raw.startsWith("{")) return null;
  try {
    const parsed = JSON.parse(raw) as ServiceAccount;
    if (parsed.type && parsed.type !== "service_account") return null;
    if (!parsed.project_id || !parsed.client_email || !parsed.private_key) {
      return null;
    }
    parsed.private_key = normalizePrivateKey(parsed.private_key);
    return parsed;
  } catch {
    return null;
  }
}

function normalizePrivateKey(pem: string): string {
  if (pem.includes("\\n")) {
    return pem.replace(/\\n/g, "\n");
  }
  return pem;
}

async function pemToCryptoKey(pem: string): Promise<CryptoKey> {
  const pemContents = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s/g, "");
  const binary = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey(
    "pkcs8",
    binary,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
}

async function getAccessToken(sa: ServiceAccount): Promise<string> {
  const key = await pemToCryptoKey(sa.private_key);
  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      exp: getNumericDate(60 * 60),
      iat: getNumericDate(0),
    },
    key,
  );
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!res.ok) {
    throw new Error(`OAuth token failed: ${await res.text()}`);
  }
  const json = await res.json();
  return String(json.access_token ?? "");
}

async function sendFcmV1(
  sa: ServiceAccount,
  token: string,
  title: string,
  message: string,
  data: Record<string, string>,
): Promise<SendResult> {
  try {
    const accessToken = await getAccessToken(sa);
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title, body: message },
            data,
            android: {
              priority: "HIGH",
              notification: {
                channel_id: "beauty_routine_challenge",
                sound: "default",
              },
            },
          },
        }),
      },
    );
    const text = await response.text();
    if (response.ok) return { ok: true, invalidToken: false };
    console.error("FCM v1 error", text);
    const invalidToken = text.includes("NOT_FOUND") ||
      text.includes("UNREGISTERED") ||
      text.includes("InvalidRegistration");
    let errorMsg = `FCM v1 ${response.status}: ${text.slice(0, 240)}`;
    if (text.includes("PERMISSION_DENIED") || text.includes("403")) {
      errorMsg +=
        " — Enable Firebase Cloud Messaging API in Google Cloud Console for project verified-glam.";
    }
    return { ok: false, invalidToken, error: errorMsg };
  } catch (e) {
    const msg = String(e);
    console.error("FCM v1 exception", msg);
    return { ok: false, invalidToken: false, error: msg };
  }
}
