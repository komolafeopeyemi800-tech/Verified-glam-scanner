import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const FUNCTION_VERSION = "2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "X-Function-Version": FUNCTION_VERSION,
};

const FALLBACK_MODEL = "gpt-4o-mini";

const ALLOWED_MODELS = new Set([
  "gpt-4o-mini",
  "gpt-4o",
  "gpt-4o-2024-08-06",
  "gpt-4o-2024-11-20",
]);

function resolveModel(requested: string): string {
  const model = requested.trim();
  if (ALLOWED_MODELS.has(model)) return model;
  console.warn(`Invalid OPENAI_MODEL "${model}", using ${FALLBACK_MODEL}`);
  return FALLBACK_MODEL;
}

function responseHeaders(extra: Record<string, string> = {}): Record<string, string> {
  return { ...corsHeaders, ...extra };
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

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnon = Deno.env.get("SUPABASE_ANON_KEY")!;
    const openaiKey = Deno.env.get("OPENAI_API_KEY")?.trim();
    const openaiModel = resolveModel(
      Deno.env.get("OPENAI_MODEL") ?? FALLBACK_MODEL,
    );

    if (!openaiKey) {
      return jsonError(503, "OPENAI_API_KEY not configured on Edge Function");
    }

    const userClient = createClient(supabaseUrl, supabaseAnon, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user) {
      return jsonError(401, "Invalid session");
    }

    const body = await req.json();
    const profile = body.profile ?? {};

    const payload = await fetchGuideRecommendations({
      apiKey: openaiKey,
      model: openaiModel,
      profile,
    });

    return new Response(JSON.stringify({ ...payload, version: FUNCTION_VERSION }), {
      headers: responseHeaders({ "Content-Type": "application/json" }),
    });
  } catch (e) {
    console.error(e);
    return jsonError(500, e instanceof Error ? e.message : "Guide recommendations failed");
  }
});

function jsonError(status: number, message: string) {
  return new Response(
    JSON.stringify({ error: message, version: FUNCTION_VERSION }),
    {
      status,
      headers: responseHeaders({ "Content-Type": "application/json" }),
    },
  );
}

async function callOpenAIText(opts: {
  apiKey: string;
  model: string;
  system: string;
  userText: string;
}): Promise<string> {
  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${opts.apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: opts.model,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: opts.system },
        { role: "user", content: opts.userText },
      ],
      max_tokens: 2048,
    }),
  });

  const rawText = await res.text();
  if (!res.ok) {
    throw new Error(`OpenAI error: ${rawText}`);
  }

  const json = JSON.parse(rawText);
  const choice = json.choices?.[0];
  const content = choice?.message?.content;
  const refusal = choice?.message?.refusal;
  const finishReason = choice?.finish_reason;

  if (content) return content;

  console.error("OpenAI empty content", {
    finishReason,
    refusal,
    model: opts.model,
    responsePreview: rawText.slice(0, 4000),
  });

  if (finishReason === "content_filter" || refusal) {
    throw new Error("Recommendations blocked by content policy.");
  }

  throw new Error(
    `Empty OpenAI response (finish_reason=${finishReason ?? "unknown"})`,
  );
}

async function fetchGuideRecommendations(opts: {
  apiKey: string;
  model: string;
  profile: Record<string, unknown>;
}): Promise<Record<string, unknown>> {
  const system =
    "You are a beauty wellness guide for Verified Glam. Output ONLY valid JSON. " +
    "Give practical, non-medical skincare and makeup tips based on the user profile. " +
    "Never diagnose conditions or prescribe treatments. Use friendly creator tone.\n\n" +
    'Schema: { "tips": [{ "title": string, "body": string }] (3-5 items), "summary": string (one sentence) }';

  const userText =
    `Generate personalized daily beauty tips for this user profile: ${JSON.stringify(opts.profile)}. ` +
    "Consider skin type, concerns, goals, product preferences, and aesthetic style. " +
    "Return JSON only.";

  const callOpts = { apiKey: opts.apiKey, system, userText };

  let content: string;
  try {
    content = await callOpenAIText({ ...callOpts, model: opts.model });
  } catch (firstError) {
    if (opts.model !== FALLBACK_MODEL) {
      console.warn(`Retrying guide with ${FALLBACK_MODEL} after failure on ${opts.model}`);
      content = await callOpenAIText({ ...callOpts, model: FALLBACK_MODEL });
    } else {
      throw firstError;
    }
  }

  const parsed = JSON.parse(content) as Record<string, unknown>;
  const tips = (parsed.tips as Record<string, unknown>[]) ?? [];

  return {
    tips: tips.slice(0, 5).map((t) => ({
      title: t.title ?? "Tip",
      body: t.body ?? "",
    })),
    summary: parsed.summary ?? "Personalized tips based on your profile.",
  };
}
