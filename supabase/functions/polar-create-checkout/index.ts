import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { Polar } from "https://esm.sh/@polar-sh/sdk@0.32.16";
import { polarProductIds } from "../_shared/credits.ts";

const FUNCTION_VERSION = "1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "X-Function-Version": FUNCTION_VERSION,
};

const VALID_PLANS = new Set(["annual", "pro_weekly"]);

function responseHeaders(extra: Record<string, string> = {}): Record<string, string> {
  return { ...corsHeaders, ...extra };
}

function jsonError(status: number, message: string) {
  return new Response(
    JSON.stringify({ error: message, version: FUNCTION_VERSION }),
    {
      status,
      headers: responseHeaders({ "Content-Type": "application/json" }),
    },
  );
}

function productIdForPlan(planId: string): string | null {
  const ids = polarProductIds();
  if (planId === "annual") return ids.annual;
  if (planId === "pro_weekly") return ids.proWeekly;
  return null;
}

function polarServer(): "sandbox" | "production" {
  return Deno.env.get("POLAR_ENV") === "production" ? "production" : "sandbox";
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: responseHeaders() });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonError(401, "Missing authorization");
    }

    const accessToken = Deno.env.get("POLAR_ACCESS_TOKEN")?.trim();
    if (!accessToken) {
      return jsonError(503, "POLAR_ACCESS_TOKEN not configured");
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnon = Deno.env.get("SUPABASE_ANON_KEY")!;
    const userClient = createClient(supabaseUrl, supabaseAnon, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user) {
      return jsonError(401, "Invalid session");
    }

    const body = await req.json();
    const planId = typeof body.planId === "string" ? body.planId.trim() : "";
    if (!VALID_PLANS.has(planId)) {
      return jsonError(400, "Invalid planId");
    }

    const productId = productIdForPlan(planId);
    if (!productId) {
      return jsonError(503, "Polar product ID not configured");
    }

    const successUrl = Deno.env.get("POLAR_SUCCESS_URL") ??
      "https://scanner.verifiedglam.com/pricing?checkout=success";

    const polar = new Polar({ accessToken, server: polarServer() });
    const checkout = await polar.checkouts.create({
      products: [productId],
      externalCustomerId: userData.user.id,
      customerEmail: userData.user.email ?? undefined,
      successUrl,
    });

    if (!checkout.url) {
      return jsonError(500, "Polar did not return a checkout URL");
    }

    return new Response(
      JSON.stringify({ checkoutUrl: checkout.url, version: FUNCTION_VERSION }),
      { headers: responseHeaders({ "Content-Type": "application/json" }) },
    );
  } catch (e) {
    console.error(e);
    return jsonError(500, e instanceof Error ? e.message : "Checkout failed");
  }
});
