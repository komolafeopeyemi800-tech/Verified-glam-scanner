import { encodeBase64 } from "https://deno.land/std@0.224.0/encoding/base64.ts";
import { Image } from "https://deno.land/x/imagescript@1.3.0/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import {
  CREDITS_PER_GENERATION,
  logCreditTransaction,
} from "../_shared/credits.ts";
import {
  APPEARANCE_OFFSETS,
  APPEARANCE_WEIGHTS,
  attractivenessTierFor,
  beautyHarmonyTierFor,
  boostScoreMap,
  deriveOverall,
  displayBoost,
  displayBoostOutOf10,
  ensureCelebritySpread,
  ensureSpread,
  FACE_BEAUTY_OFFSETS,
  FACE_BEAUTY_WEIGHTS,
  FACE_SCORING_RUBRIC,
  parseNumericScore,
  SYMMETRY_REGION_DEFAULTS,
  SYMMETRY_REGION_OFFSETS,
  SYMMETRY_SUB_OFFSETS,
  SYMMETRY_SUB_WEIGHTS,
  symmetryTierFor,
  TRAIT_OFFSETS,
} from "./scoring.ts";

const FUNCTION_VERSION = "10";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "X-Function-Version": FUNCTION_VERSION,
};

const ALLOWED_MODELS = new Set([
  "gpt-4o-mini",
  "gpt-4o",
  "gpt-4o-2024-08-06",
  "gpt-4o-2024-11-20",
]);

const VALID_FEATURES = [
  "FACE_BEAUTY_ANALYSIS",
  "COLOR_ANALYSIS",
  "GLOW_UP_GUIDE",
  "BEAUTY_TIPS",
  "CELEBRITY_LOOKALIKE",
  "FACIAL_SYMMETRY",
  "BEAUTY_SCORE_SHOWDOWN",
  "FACIAL_RESEMBLANCE",
  "FACE_READING",
  "GOLDEN_RATIO",
] as const;

type FeatureType = (typeof VALID_FEATURES)[number];

const YEARLY_CREDITS_ALLOCATION = 200;
const PRO_WEEKLY_CREDITS_ALLOCATION = 30;
const FALLBACK_MODEL = "gpt-4o-mini";

const HIGH_DETAIL_FEATURES = new Set<FeatureType>([
  "BEAUTY_TIPS",
  "GLOW_UP_GUIDE",
  "CELEBRITY_LOOKALIKE",
  "FACE_BEAUTY_ANALYSIS",
  "COLOR_ANALYSIS",
  "FACIAL_SYMMETRY",
  "FACE_READING",
  "GOLDEN_RATIO",
]);

const BEAUTY_CATEGORY_IDS = [
  "acne",
  "hyperpigmentation",
  "texture_scars",
  "aging",
  "sensitivity",
  "oily_pores",
  "dryness",
  "uneven_tone",
] as const;

type BeautyCatalog = {
  globalDisclaimer: string;
  categories: Record<string, unknown>[];
  tipsByCategory: Record<string, Record<string, unknown[]>>;
  spotLabels: Record<string, string>;
};

function resolveModel(requested: string): string {
  const model = requested.trim();
  if (ALLOWED_MODELS.has(model)) return model;
  console.warn(`Invalid OPENAI_MODEL "${model}", using ${FALLBACK_MODEL}`);
  return FALLBACK_MODEL;
}

function responseHeaders(extra: Record<string, string> = {}): Record<string, string> {
  return { ...corsHeaders, ...extra };
}

async function prepareImageBytes(
  bytes: Uint8Array,
  mime: string,
): Promise<{ bytes: Uint8Array; mime: string }> {
  const maxEdge = 768;
  try {
    const img = await Image.decode(bytes);
    if (Math.max(img.width, img.height) > maxEdge) {
      const scale = maxEdge / Math.max(img.width, img.height);
      img.resize(
        Math.max(1, Math.round(img.width * scale)),
        Math.max(1, Math.round(img.height * scale)),
      );
    }
    return { bytes: await img.encodeJPEG(85), mime: "image/jpeg" };
  } catch (e) {
    console.warn("prepareImageBytes: decode/resize failed, using original", e);
    return { bytes, mime: mime || "image/jpeg" };
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: responseHeaders() });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonError(401, "Missing authorization", "UNAUTHORIZED");
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnon = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const openaiKey = Deno.env.get("OPENAI_API_KEY")?.trim();
    const openaiModel = resolveModel(
      Deno.env.get("OPENAI_MODEL") ?? FALLBACK_MODEL,
    );

    if (!openaiKey) {
      return jsonError(503, "OPENAI_API_KEY not configured on Edge Function", "SERVICE_UNAVAILABLE");
    }

    const userClient = createClient(supabaseUrl, supabaseAnon, {
      global: { headers: { Authorization: authHeader } },
    });
    const admin = createClient(supabaseUrl, serviceKey);

    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user) {
      return jsonError(401, "Invalid session", "UNAUTHORIZED");
    }
    const userId = userData.user.id;

    const body = await req.json();
    const featureType = body.featureType as string;
    const storagePath = body.storagePath as string;
    const detectedFaces = body.detectedFaces ?? [];
    const profile = body.profile ?? {};

    if (!VALID_FEATURES.includes(featureType as FeatureType)) {
      return jsonError(400, `Unknown featureType: ${featureType}`, "INVALID_REQUEST");
    }
    if (!storagePath || !storagePath.startsWith(`${userId}/`)) {
      return jsonError(400, "Invalid storagePath", "INVALID_REQUEST");
    }

    await checkCredits(admin, userId);

    const { data: signed, error: signError } = await admin.storage
      .from("scan-photos")
      .createSignedUrl(storagePath, 300);
    if (signError || !signed?.signedUrl) {
      return jsonError(400, "Could not access photo", "INVALID_IMAGE");
    }

    const imageRes = await fetch(signed.signedUrl);
    if (!imageRes.ok) {
      return jsonError(400, "Could not download photo", "INVALID_IMAGE");
    }
    const rawBytes = new Uint8Array(await imageRes.arrayBuffer());
    const prepared = await prepareImageBytes(
      rawBytes,
      imageRes.headers.get("content-type") ?? "image/jpeg",
    );
    const base64 = encodeBase64(prepared.bytes);
    const mime = prepared.mime;

    let beautyCatalog: BeautyCatalog | null = null;
    if (featureType === "BEAUTY_TIPS" || featureType === "GLOW_UP_GUIDE") {
      beautyCatalog = await loadBeautyTipsCatalog(admin);
    }

    let payload = await analyzeWithOpenAI({
      apiKey: openaiKey,
      model: openaiModel,
      featureType: featureType as FeatureType,
      base64,
      mime,
      detectedFaces,
      profile,
      beautyCatalog,
    });

    if (featureType === "CELEBRITY_LOOKALIKE") {
      payload = await enrichCelebrityMatches(payload, admin, openaiKey, supabaseUrl);
    }

    if (featureType === "BEAUTY_SCORE_SHOWDOWN") {
      payload = await enrichShowdown(
        payload,
        admin,
        openaiKey,
        supabaseUrl,
        userId,
      );
    }

    const creditsRemaining = await deductCredits(admin, userId, featureType);

    return new Response(JSON.stringify({
      payload,
      version: FUNCTION_VERSION,
      creditsRemaining,
    }), {
      headers: responseHeaders({ "Content-Type": "application/json" }),
    });
  } catch (e) {
    console.error(e);
    if (e instanceof AnalysisError) {
      return jsonError(e.status, e.message, e.errorCode);
    }
    const msg = e instanceof Error ? e.message : "Analysis failed";
    if (msg.includes("Insufficient credits") || msg.includes("INSUFFICIENT_CREDITS")) {
      return jsonError(
        429,
        "You need 5 credits for this analysis. Credits renew with your subscription plan.",
        "INSUFFICIENT_CREDITS",
      );
    }
    if (msg.includes("Pro subscription required") || msg.includes("NOT_SUBSCRIBED")) {
      return jsonError(403, "Pro subscription required to run AI analysis.", "NOT_SUBSCRIBED");
    }
    return jsonError(500, mapOpenAIErrorMessage(msg), classifyOpenAIErrorCode(msg));
  }
});

class AnalysisError extends Error {
  status: number;
  errorCode: string;

  constructor(status: number, errorCode: string, message: string) {
    super(message);
    this.status = status;
    this.errorCode = errorCode;
  }
}

function jsonError(status: number, message: string, errorCode = "ANALYSIS_FAILED") {
  return new Response(
    JSON.stringify({ error: message, errorCode, version: FUNCTION_VERSION }),
    {
      status,
      headers: responseHeaders({ "Content-Type": "application/json" }),
    },
  );
}

function classifyOpenAIErrorCode(message: string): string {
  const lower = message.toLowerCase();
  if (lower.includes("content policy") || lower.includes("content_filter")) {
    return "CONTENT_POLICY";
  }
  if (lower.includes("invalid_image") || lower.includes("image_process")) {
    return "INVALID_IMAGE";
  }
  if (lower.includes("429") || lower.includes("rate_limit")) {
    return "RATE_LIMITED";
  }
  if (lower.includes("timeout") || lower.includes("deadline-exceeded")) {
    return "ANALYSIS_TIMEOUT";
  }
  if (lower.includes("empty openai response")) {
    return "ANALYSIS_TIMEOUT";
  }
  return "ANALYSIS_FAILED";
}

function mapOpenAIErrorMessage(message: string): string {
  const code = classifyOpenAIErrorCode(message);
  switch (code) {
    case "CONTENT_POLICY":
      return "Analysis blocked by content policy. Try a clearer front-facing photo.";
    case "INVALID_IMAGE":
      return "Could not process this image. Please use a clearer selfie.";
    case "RATE_LIMITED":
      return "Service is busy. Please wait a moment and try again.";
    case "ANALYSIS_TIMEOUT":
      return "Analysis took too long. Please try with a clearer photo.";
    default:
      return message.length > 200 ? "Something went wrong. Please try again." : message;
  }
}

function throwOpenAIError(rawText: string, status: number): never {
  const lower = rawText.toLowerCase();
  if (status === 429 || lower.includes("rate_limit")) {
    throw new AnalysisError(
      429,
      "RATE_LIMITED",
      "Service is busy. Please wait a moment and try again.",
    );
  }
  if (lower.includes("invalid_image") || lower.includes("image_process")) {
    throw new AnalysisError(
      400,
      "INVALID_IMAGE",
      "Could not process this image. Please use a clearer selfie.",
    );
  }
  throw new AnalysisError(
    500,
    classifyOpenAIErrorCode(rawText),
    mapOpenAIErrorMessage(rawText),
  );
}

async function loadBeautyTipsCatalog(
  admin: ReturnType<typeof createClient>,
): Promise<BeautyCatalog> {
  const [{ data: categories }, { data: entries }, { data: labels }, { data: content }] =
    await Promise.all([
      admin.from("beauty_tip_categories").select("*").order("sort_order"),
      admin.from("beauty_tip_entries").select("*").order("sort_order"),
      admin.from("beauty_spot_label_map").select("issue_tag, display_label"),
      admin.from("app_content").select("value").eq("key", "beauty_tips_global_disclaimer").maybeSingle(),
    ]);

  const tipsByCategory: Record<string, Record<string, unknown[]>> = {};
  for (const entry of entries ?? []) {
    const cat = entry.category_id as string;
    const sev = entry.severity as string;
    tipsByCategory[cat] ??= {};
    tipsByCategory[cat][sev] ??= [];
    tipsByCategory[cat][sev].push({
      title: entry.title,
      body: entry.body,
      sortOrder: entry.sort_order,
    });
  }

  const spotLabels: Record<string, string> = {};
  for (const row of labels ?? []) {
    spotLabels[row.issue_tag as string] = row.display_label as string;
  }

  return {
    globalDisclaimer: (content?.value as string) ??
      "Verified Glam does not provide medical diagnosis or treatment. Tips reflect community experiences only.",
    categories: categories ?? [],
    tipsByCategory,
    spotLabels,
  };
}

type ProfileCredits = {
  is_pro: boolean | null;
  subscription_plan: string | null;
  credits_balance: number | null;
  credits_period_key: string | null;
  credits_allocated: number | null;
};

function currentPeriodKey(plan: string): string {
  const now = new Date();
  if (plan === "pro_weekly") {
    const d = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    const weekNo = Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7);
    return `${d.getUTCFullYear()}-W${String(weekNo).padStart(2, "0")}`;
  }
  return String(now.getUTCFullYear());
}

function allocationForPlan(plan: string): number {
  if (plan === "pro_weekly") return PRO_WEEKLY_CREDITS_ALLOCATION;
  if (plan === "annual") return YEARLY_CREDITS_ALLOCATION;
  return 0;
}

async function loadProfileCredits(
  admin: ReturnType<typeof createClient>,
  userId: string,
): Promise<ProfileCredits> {
  const { data, error } = await admin
    .from("profiles")
    .select("is_pro, subscription_plan, credits_balance, credits_period_key, credits_allocated")
    .eq("id", userId)
    .single();
  if (error || !data) {
    throw new AnalysisError(403, "NOT_SUBSCRIBED", "Profile not found.");
  }
  return data as ProfileCredits;
}

async function refreshCreditsIfNeeded(
  admin: ReturnType<typeof createClient>,
  userId: string,
  profile: ProfileCredits,
): Promise<ProfileCredits> {
  const plan = profile.subscription_plan ?? "free";
  if (!profile.is_pro || plan === "free") return profile;

  const periodKey = currentPeriodKey(plan);
  const allocated = allocationForPlan(plan);
  if (profile.credits_period_key === periodKey && (profile.credits_allocated ?? 0) === allocated) {
    return profile;
  }

  const { data, error } = await admin
    .from("profiles")
    .update({
      credits_balance: allocated,
      credits_allocated: allocated,
      credits_period_key: periodKey,
      subscription_plan: plan,
      is_pro: true,
      updated_at: new Date().toISOString(),
    })
    .eq("id", userId)
    .select("is_pro, subscription_plan, credits_balance, credits_period_key, credits_allocated")
    .single();

  if (error || !data) {
    throw new AnalysisError(500, "ANALYSIS_FAILED", "Could not refresh credits.");
  }
  return data as ProfileCredits;
}

async function checkCredits(
  admin: ReturnType<typeof createClient>,
  userId: string,
): Promise<void> {
  let profile = await loadProfileCredits(admin, userId);
  if (!profile.is_pro) {
    throw new AnalysisError(
      403,
      "NOT_SUBSCRIBED",
      "Pro subscription required to run AI analysis.",
    );
  }

  profile = await refreshCreditsIfNeeded(admin, userId, profile);
  const balance = profile.credits_balance ?? 0;
  if (balance < CREDITS_PER_GENERATION) {
    throw new AnalysisError(
      429,
      "INSUFFICIENT_CREDITS",
      "You need 5 credits for this analysis. Credits renew with your subscription plan.",
    );
  }
}

async function deductCredits(
  admin: ReturnType<typeof createClient>,
  userId: string,
  featureType: string,
): Promise<number> {
  const { data: profile } = await admin
    .from("profiles")
    .select("credits_balance")
    .eq("id", userId)
    .single();

  const balance = profile?.credits_balance ?? 0;
  const remaining = Math.max(0, balance - CREDITS_PER_GENERATION);
  await admin.from("profiles").update({
    credits_balance: remaining,
    updated_at: new Date().toISOString(),
  }).eq("id", userId);

  await logCreditTransaction(admin, userId, {
    amount: -CREDITS_PER_GENERATION,
    kind: "analysis",
    description: featureLabelForCredits(featureType),
    featureType,
    balanceAfter: remaining,
  });

  return remaining;
}

function featureLabelForCredits(featureType: string): string {
  const labels: Record<string, string> = {
    FACE_BEAUTY_ANALYSIS: "Face Beauty Analysis",
    GOLDEN_RATIO: "Golden Ratio Analysis",
    CELEBRITY_LOOKALIKE: "Celebrity Look-Alike",
    FACIAL_SYMMETRY: "Facial Symmetry Analysis",
    BEAUTY_TIPS: "Beauty Tips Analysis",
    GLOW_UP_GUIDE: "Glow Up Guide",
    FACIAL_RESEMBLANCE: "Face Comparison",
    FACE_READING: "Face Reading",
    BEAUTY_SCORE_SHOWDOWN: "Beauty Score Showdown",
    COLOR_ANALYSIS: "Seasonal Color Palette",
    APPEARANCE_ANALYSIS: "Appearance Analysis",
  };
  return labels[featureType] ?? featureType.replace(/_/g, " ");
}

async function enforceDailyLimit(
  admin: ReturnType<typeof createClient>,
  userId: string,
) {
  const today = new Date().toISOString().slice(0, 10);
  const { data: profile } = await admin
    .from("profiles")
    .select("daily_scan_count, daily_scan_date")
    .eq("id", userId)
    .single();

  let count = profile?.daily_scan_count ?? 0;
  const date = profile?.daily_scan_date;
  if (date !== today) count = 0;
  if (count >= DAILY_SCAN_LIMIT) {
    throw new AnalysisError(
      429,
      "DAILY_LIMIT",
      `Daily scan limit (${DAILY_SCAN_LIMIT}) reached. Try again tomorrow.`,
    );
  }
}

async function incrementDailyScan(
  admin: ReturnType<typeof createClient>,
  userId: string,
) {
  const today = new Date().toISOString().slice(0, 10);
  const { data: profile } = await admin
    .from("profiles")
    .select("daily_scan_count, daily_scan_date")
    .eq("id", userId)
    .single();

  let count = profile?.daily_scan_count ?? 0;
  if (profile?.daily_scan_date !== today) count = 0;
  await admin.from("profiles").update({
    daily_scan_count: count + 1,
    daily_scan_date: today,
  }).eq("id", userId);
}

async function callOpenAI(opts: {
  apiKey: string;
  model: string;
  system: string;
  userText: string;
  base64: string;
  mime: string;
  imageDetail?: "low" | "high" | "auto";
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
        {
          role: "user",
          content: [
            { type: "text", text: opts.userText },
            {
              type: "image_url",
              image_url: {
                url: `data:${opts.mime};base64,${opts.base64}`,
                detail: opts.imageDetail ?? "low",
              },
            },
          ],
        },
      ],
      max_tokens: 4096,
    }),
  });

  const rawText = await res.text();
  if (!res.ok) {
    throwOpenAIError(rawText, res.status);
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
    throw new AnalysisError(
      422,
      "CONTENT_POLICY",
      "Analysis blocked by content policy. Try a clearer front-facing photo.",
    );
  }

  throw new AnalysisError(
    504,
    "ANALYSIS_TIMEOUT",
    "Analysis took too long. Please try with a clearer photo.",
  );
}

async function analyzeWithOpenAI(opts: {
  apiKey: string;
  model: string;
  featureType: FeatureType;
  base64: string;
  mime: string;
  detectedFaces: unknown;
  profile: Record<string, unknown>;
  beautyCatalog: BeautyCatalog | null;
}): Promise<Record<string, unknown>> {
  const system = buildSystemPrompt(opts.featureType, opts.beautyCatalog);
  const userText = buildUserPrompt(
    opts.featureType,
    opts.detectedFaces,
    opts.profile,
    opts.beautyCatalog,
  );

  const imageDetail = HIGH_DETAIL_FEATURES.has(opts.featureType) ? "high" : "low";

  const callOpts = {
    apiKey: opts.apiKey,
    system,
    userText,
    base64: opts.base64,
    mime: opts.mime,
    imageDetail,
  };

  const shortSystem =
    "Output ONLY valid JSON for facial analysis. Neutral observations only. No medical claims.";

  let content: string | null = null;
  let lastError: Error | null = null;

  for (const model of [opts.model, FALLBACK_MODEL].filter((m, i, a) =>
    a.indexOf(m) === i
  )) {
    try {
      content = await callOpenAI({ ...callOpts, model });
      break;
    } catch (e) {
      lastError = e instanceof Error ? e : new Error(String(e));
      const msg = lastError.message;
      if (!msg.includes("Empty OpenAI response") &&
        !msg.includes("content policy")) {
        throw lastError;
      }
      console.warn(`OpenAI attempt failed on ${model}: ${msg}`);
    }
  }

  if (!content) {
    try {
      content = await callOpenAI({
        ...callOpts,
        model: FALLBACK_MODEL,
        system: shortSystem,
      });
    } catch (e) {
      throw lastError ?? (e instanceof Error ? e : new Error(String(e)));
    }
  }

  const parsed = JSON.parse(content) as Record<string, unknown>;
  assertFaceDetected(opts.featureType, parsed, opts.detectedFaces);
  if (opts.featureType === "CELEBRITY_LOOKALIKE") {
    return normalizeCelebrityPayload(parsed);
  }
  return normalizePayload(
    opts.featureType,
    parsed,
    opts.beautyCatalog,
    opts.detectedFaces,
  );
}

const FACE_REQUIRED_FEATURES = new Set<FeatureType>([
  "FACE_BEAUTY_ANALYSIS",
  "COLOR_ANALYSIS",
  "BEAUTY_TIPS",
  "GLOW_UP_GUIDE",
  "CELEBRITY_LOOKALIKE",
  "FACIAL_SYMMETRY",
  "BEAUTY_SCORE_SHOWDOWN",
  "FACIAL_RESEMBLANCE",
  "FACE_READING",
  "GOLDEN_RATIO",
]);

function assertFaceDetected(
  featureType: FeatureType,
  parsed: Record<string, unknown>,
  detectedFaces: unknown,
): void {
  if (!FACE_REQUIRED_FEATURES.has(featureType)) return;

  const explicitCode = String(parsed.errorCode ?? parsed.error ?? "").toUpperCase();
  if (explicitCode.includes("NO_FACE")) {
    throw new AnalysisError(
      422,
      "NO_FACE_DETECTED",
      "We couldn't detect a face in this photo. Please try again with a clearer photo.",
    );
  }

  if (parsed.noFaceDetected === true || parsed.faceDetected === false) {
    throw new AnalysisError(
      422,
      "NO_FACE_DETECTED",
      "We couldn't detect a face in this photo. Please try again with a clearer photo.",
    );
  }

  const clientFaces = Array.isArray(detectedFaces) ? detectedFaces : [];
  if (featureType === "FACIAL_RESEMBLANCE" && clientFaces.length < 2) {
    // Web clients cannot run on-device face detection; trust AI faceCount / faces / payload.
    const aiFaces = Array.isArray(parsed.faces) ? (parsed.faces as unknown[]) : [];
    const faceCount =
      toInt(parsed.faceCount) ??
      (aiFaces.length >= 2 ? aiFaces.length : null) ??
      (parsed.similarity != null ? 2 : clientFaces.length);
    if (faceCount < 2) {
      throw new AnalysisError(
        422,
        "NO_FACE_DETECTED",
        "We need two clear faces for face comparison. Please try again with a photo showing both people.",
      );
    }
  }

  if (clientFaces.length === 0) {
    const hasFaceSignal = parsed.beautyScore != null ||
      parsed.overallScore != null ||
      parsed.overallSymmetryScore != null ||
      parsed.overallPercent != null ||
      (Array.isArray(parsed.spots) && (parsed.spots as unknown[]).length > 0) ||
      (Array.isArray(parsed.matches) && (parsed.matches as unknown[]).length > 0) ||
      (Array.isArray(parsed.regions) && (parsed.regions as unknown[]).length > 0);

    if (!hasFaceSignal && parsed.noFaceDetected !== false) {
      const message = String(parsed.message ?? "").toLowerCase();
      if (
        message.includes("no face") ||
        message.includes("couldn't detect") ||
        message.includes("cannot detect")
      ) {
        throw new AnalysisError(
          422,
          "NO_FACE_DETECTED",
          "We couldn't detect a face in this photo. Please try again with a clearer photo.",
        );
      }
    }
  }
}

function buildSystemPrompt(
  featureType: FeatureType,
  catalog: BeautyCatalog | null,
): string {
  const base =
    "You are a facial analysis assistant for Verified Glam. Output ONLY valid JSON. " +
    "Focus on neutral visual observations: proportions, symmetry, color harmony, and wellness-style suggestions. " +
    "Never provide medical diagnosis, prescriptions, or cure claims. " +
    "Use 'may help', 'some people say', 'creators share' — not 'will cure' or 'treats'. " +
    "Do not rank people as more or less attractive — describe proportions and harmony objectively. " +
    "For normalized face coordinates use 0-1 (x left-right, y top-bottom).";

  const schemas: Record<FeatureType, string> = {
    FACE_BEAUTY_ANALYSIS:
      'Return: { "beautyScore": number (0-100, must equal weighted avg of subscores), "ratingLabel": string, "subscores": { "symmetry", "featureBalance", "skinQuality", "youthfulCues", "overallBeauty" } (each integer 0-100, all different), "annotations": [{ "text", "anchor": {x,y}, "labelSide" }] }',
    COLOR_ANALYSIS:
      'Return: { "season": string, "skin": hex, "palette": [hex...], "description": string }',
    GLOW_UP_GUIDE:
      'Return: { "spots": [{ "id", "categoryId", "label", "anchor": {x,y}, "severity": "high"|"medium"|"low", "confidence", "labelSide", "color" (ARGB int) }], "findings": [...], "summary", "globalDisclaimer" }. Up to 10 visible spots only. Do NOT include tips[] or days[].',
    BEAUTY_TIPS:
      'Return: { "spots": [{ "id", "categoryId", "label", "anchor": {x,y}, "severity": "high"|"medium"|"low", "confidence", "labelSide", "color" (ARGB int) }], "findings": [...], "summary", "globalDisclaimer" }. Up to 10 visible spots only. Do NOT include tips[].',
    CELEBRITY_LOOKALIKE:
      'Return: { "detectedGender": "female"|"male"|"unknown", "matches": [{ "name", "percent" (integer 60-95, descending with 6-12 pt gaps), "traits": [string], "why": string }] } — exactly 3 to 5 well-known public figures. Style resemblance only.',
    FACIAL_SYMMETRY:
      'Return: { "overallSymmetryScore": number (0-100), "overallPercent": number (same as overallSymmetryScore), "tierLabel": string, "guides": { "verticalCenter", "verticalSideLines": [number], "horizontalLines": [number] }, "regions": [{ "id": "eyebrow"|"eyes"|"nose"|"mouth"|"cheeks", "label", "percent" (integer 0-100, each unique), "anchor": {x,y}, "labelSide" }], "subscores": { "beauty", "cuteness", "skinSmoothness", "handsomeness", "faceShape", "facialSymmetry" } (integers 0-100, all different), "annotations": [{ "text", "anchor", "labelSide" }] }',
    BEAUTY_SCORE_SHOWDOWN:
      'Return: { "yourScore": number (0-10 harmony), "rankPosition", "totalParticipants", "averageScore": number (0-10), "rankLabel", "engagementNote", "podium": [{ "name", "displayName", "score" (0-10), "rank" }] }',
    FACIAL_RESEMBLANCE:
      'Return: { "faceCount": number (2 for two-person photos), "similarity": number (0-100), "scoreLabel", "relationship"|"relationshipHint", "sharedTraits": [string], "contourComparison", "explanation" }',
    FACE_READING:
      'Return: { "overallScore": number (0-10, derived from appearanceScores avg), "tierLabel": string, "facialAge", "appearanceScores": { "beauty", "handsomeness", "cuteness", "faceShape", "facialSymmetry", "skinSmoothness" } (integers 0-100, all different), "traitScores": { "funFactor", "intelligence", "confidence", "credibility" } (integers 0-100, all different), "faceBox", "landmarks", "meshConnections" }',
    GOLDEN_RATIO:
      'Return: { "overallScore": number, "goldenRatioIndex": number (0-100), "ratingLabel", "idealPhi": 1.618, "measurements": [{ "id", "name", "ratio", "ideal", "delta", "scoreOutOf20", "pass", "from": {x,y}, "to": {x,y}, "labelSide" }], "landmarks": { "hairline", "chin", "eyeInnerL", ... }, "deviations": [string], "harmonyPercent" }',
  };

  let prompt = `${base}\n\nFeature: ${featureType}\nSchema: ${schemas[featureType]}`;

  const faceScoringFeatures: FeatureType[] = [
    "FACE_BEAUTY_ANALYSIS",
    "FACIAL_SYMMETRY",
    "FACE_READING",
    "CELEBRITY_LOOKALIKE",
  ];
  if (faceScoringFeatures.includes(featureType)) {
    prompt += FACE_SCORING_RUBRIC;
  }

  if (featureType === "CELEBRITY_LOOKALIKE") {
    prompt +=
      "\n\nCELEBRITY LOOK-ALIKE RULES:\n" +
      "- Analyze THIS specific portrait only — face shape, eyes, nose, lips, jaw, cheekbones, hair.\n" +
      "- Return 3–5 matches sorted by percent descending. Never return an empty matches array.\n" +
      "- Each match needs 2–4 trait strings and a one-sentence why referencing visible features.\n" +
      "- Use real, recognizable celebrity names only. Percent is playful style resemblance (60–95).\n" +
      "- Match percents must descend with 6–12 point gaps; highest match = strongest trait overlap.\n" +
      "- This is entertainment — not biometric identification.";
  }

  if (featureType === "FACIAL_SYMMETRY") {
    prompt +=
      "\n\nFACIAL SYMMETRY RULES:\n" +
      "- Return exactly 5 regions: eyebrow, eyes, nose, mouth, cheeks — each with its own percent.\n" +
      "- Region percents must differ; score left/right balance per region from THIS photo.";
  }

  if (featureType === "FACIAL_RESEMBLANCE") {
    prompt +=
      "\n\nFACE COMPARISON RULES:\n" +
      "- Photo must show exactly two clear faces. Always set faceCount to 2.\n" +
      "- Score outer contour and feature alignment between both faces only.";
  }

  if (featureType === "FACE_BEAUTY_ANALYSIS") {
    prompt +=
      "\n\nFACE BEAUTY WEIGHTS: symmetry 1.2, featureBalance 1.1, skinQuality 1.0, youthfulCues 0.9, overallBeauty 1.0.";
  }

  if (featureType === "FACE_READING") {
    prompt +=
      "\n\nATTRACTIVENESS WEIGHTS (appearance): beauty 1.2, facialSymmetry 1.1, skinSmoothness 1.0, faceShape 1.0, handsomeness 0.9, cuteness 0.8.";
  }

  const photoSpecificFeatures: FeatureType[] = [
    "FACE_BEAUTY_ANALYSIS",
    "COLOR_ANALYSIS",
    "FACIAL_SYMMETRY",
    "FACE_READING",
    "GOLDEN_RATIO",
    "FACIAL_RESEMBLANCE",
    "BEAUTY_SCORE_SHOWDOWN",
  ];
  if (photoSpecificFeatures.includes(featureType)) {
    prompt +=
      "\n\nAnalyze THIS portrait only. Scores, colors, and findings must reflect visible features in this photo — not generic templates.";
  }

  const skinScan = featureType === "BEAUTY_TIPS" || featureType === "GLOW_UP_GUIDE";
  if (skinScan && catalog) {
    const slimCategories = catalog.categories.map((c) => ({
      id: c.id,
      name: c.name,
      short_label: c.short_label,
      color: c.color,
      label_side: c.label_side,
    }));

    prompt +=
      "\n\nBEAUTY TIPS RULES:\n" +
      "- Only mark spots that are VISIBLY present in this photo. Do NOT invent acne, pimples, redness, or texture issues.\n" +
      "- Each spot must include confidence (0–1). Skip anything below 0.55 confidence.\n" +
      "- Detect up to 10 distinct visible spots with accurate normalized anchors.\n" +
      "- Keep anchors at least 0.05 apart (normalized). Balance labelSide left/right by anchor x position.\n" +
      "- Summary must describe what is visible in THIS portrait.\n" +
      `- categoryId must be one of: ${BEAUTY_CATEGORY_IDS.join(", ")}.\n` +
      "- Use spotLabels and category metadata for overlay labels and colors.\n" +
      "- Set globalDisclaimer exactly from the knowledge base.\n" +
      (featureType === "GLOW_UP_GUIDE"
        ? "- Do not generate tips[] or days[] — only spots, findings, summary, globalDisclaimer.\n"
        : "- Do not generate tips[] — only spots, findings, summary, globalDisclaimer.\n") +
      `\nKNOWLEDGE BASE (metadata only):\n${JSON.stringify({
        globalDisclaimer: catalog.globalDisclaimer,
        categories: slimCategories,
        spotLabels: catalog.spotLabels,
      })}`;
  }

  return prompt;
}

function buildUserPrompt(
  featureType: FeatureType,
  detectedFaces: unknown,
  profile: Record<string, unknown>,
  catalog: BeautyCatalog | null,
): string {
  let text =
    `Analyze this portrait for ${featureType}. ` +
    `User profile context: ${JSON.stringify(profile)}. ` +
    `On-device face hints (optional): ${JSON.stringify(detectedFaces)}. ` +
    `Return the JSON payload only.`;

  if ((featureType === "BEAUTY_TIPS" || featureType === "GLOW_UP_GUIDE") && catalog) {
    text +=
      " Only label visibly present skin concerns. Place anchors on visible areas with min 0.05 separation. Group findings by categoryId with spotCount.";
  }

  if (featureType === "CELEBRITY_LOOKALIKE") {
    text += " Return 3–5 celebrity matches with traits and why for this specific face.";
  }

  return text;
}

function mergeTipsFromCatalog(
  catalog: BeautyCatalog,
  spots: Record<string, unknown>[],
  findings: Record<string, unknown>[],
): Record<string, unknown>[] {
  const perTipDisclaimer =
    "Community tip — not medical advice. Patch test first.";

  const pairs = new Map<string, string>();
  for (const spot of spots) {
    const cat = spot.categoryId as string;
    const sev = (spot.severity as string) ?? "medium";
    if (cat) pairs.set(`${cat}:${sev}`, sev);
  }
  for (const finding of findings) {
    const cat = finding.categoryId as string;
    const sev = (finding.severity as string) ?? "medium";
    if (cat) pairs.set(`${cat}:${sev}`, sev);
  }

  const tips: Record<string, unknown>[] = [];
  let priority = 1;

  for (const [key] of pairs) {
    const [categoryId, severity] = key.split(":");
    const entries = catalog.tipsByCategory[categoryId]?.[severity] ?? [];
    const entry = entries[0] as Record<string, unknown> | undefined;
    if (entry) {
      tips.push({
        priority: priority++,
        categoryId,
        title: entry.title,
        body: entry.body,
        disclaimer: perTipDisclaimer,
      });
    }
  }

  if (tips.length === 0 && spots.length > 0) {
    const cat = spots[0].categoryId as string;
    const sev = (spots[0].severity as string) ?? "low";
    const entries = catalog.tipsByCategory[cat]?.[sev] ?? [];
    const entry = entries[0] as Record<string, unknown> | undefined;
    if (entry) {
      tips.push({
        priority: 1,
        categoryId: cat,
        title: entry.title,
        body: entry.body,
        disclaimer: perTipDisclaimer,
      });
    }
  }

  return tips;
}

function normalizePayload(
  featureType: FeatureType,
  parsed: Record<string, unknown>,
  catalog: BeautyCatalog | null,
  detectedFaces: unknown = [],
): Record<string, unknown> {
  if (featureType === "FACIAL_SYMMETRY") {
    return normalizeFacialSymmetry(parsed);
  }
  if (featureType === "FACIAL_RESEMBLANCE") {
    return normalizeFacialResemblance(parsed, detectedFaces);
  }
  if (featureType === "GOLDEN_RATIO") {
    return normalizeGoldenRatio(parsed, detectedFaces);
  }
  if (featureType === "FACE_BEAUTY_ANALYSIS") {
    return normalizeFaceBeauty(parsed);
  }
  if (featureType === "FACE_READING") {
    return normalizeFaceReading(parsed);
  }
  if (featureType === "BEAUTY_SCORE_SHOWDOWN") {
    return normalizeShowdown(parsed);
  }

  const skinScan = featureType === "BEAUTY_TIPS" || featureType === "GLOW_UP_GUIDE";
  if (!skinScan || !catalog) return parsed;

  let spots = asMapList(parsed.spots);
  spots = filterLowConfidenceSpots(spots, 0.55);
  spots = dedupeSpotAnchors(spots, 0.05);
  spots = balanceLabelSides(spots);
  spots = capSpotsBySeverity(spots, 10);
  parsed.spots = spots;

  const categoryMap = new Map<string, Record<string, unknown>>(
    (catalog.categories ?? []).map((c) => [c.id as string, c as Record<string, unknown>]),
  );

  if (!parsed.annotations && spots.length > 0) {
    parsed.annotations = spots.map((s, i) => {
      const cat = categoryMap.get(s.categoryId as string);
      return {
        text: s.label,
        anchor: s.anchor,
        labelSide: s.labelSide ?? cat?.label_side ?? "right",
        color: s.color ?? cat?.color ?? 0xffe07a9a,
        spotId: s.id ?? `spot_${i + 1}`,
      };
    }).slice(0, 10);
  }

  if (!parsed.findings && spots.length > 0) {
    const grouped = new Map<string, Record<string, unknown>[]>();
    for (const spot of spots) {
      const id = spot.categoryId as string;
      grouped.set(id, [...(grouped.get(id) ?? []), spot]);
    }
    parsed.findings = [...grouped.entries()].map(([categoryId, group]) => {
      const cat = categoryMap.get(categoryId);
      const severities = group.map((s) => s.severity as string);
      const severity = severities.includes("high")
        ? "high"
        : severities.includes("medium")
        ? "medium"
        : "low";
      const anchorSpot = group[0];
      return {
        categoryId,
        categoryName: cat?.name ?? categoryId,
        severity,
        shortLabel: cat?.short_label ?? "Spot",
        spotCount: group.length,
        anchor: anchorSpot?.anchor,
        labelSide: anchorSpot?.labelSide ?? cat?.label_side ?? "right",
        color: anchorSpot?.color ?? cat?.color ?? 0xffe07a9a,
      };
    });
  }

  const findings = asMapList(parsed.findings);
  parsed.findings = findings;

  if (catalog.globalDisclaimer && !parsed.globalDisclaimer) {
    parsed.globalDisclaimer = catalog.globalDisclaimer;
  }
  if (featureType === "BEAUTY_TIPS") {
    parsed.tips = mergeTipsFromCatalog(catalog, spots, findings);
  }
  parsed.detectedIssues = buildDetectedIssues(spots, findings, categoryMap);

  return parsed;
}

function severityWeight(severity: string): number {
  switch ((severity ?? "").toLowerCase()) {
    case "high":
      return 3;
    case "medium":
      return 2;
    default:
      return 1;
  }
}

function canonicalIssueId(raw: string): string {
  const v = (raw ?? "").toLowerCase();
  if (v.includes("acne") || v.includes("breakout") || v.includes("pimple")) return "acne";
  if (v.includes("pigment") || v.includes("dark") || v.includes("spot")) return "hyperpigmentation";
  if (v.includes("texture") || v.includes("scar")) return "texture_scars";
  if (v.includes("aging") || v.includes("sag") || v.includes("firm")) return "aging";
  if (v.includes("sensitive") || v.includes("redness")) return "sensitivity";
  if (v.includes("oily") || v.includes("pore") || v.includes("sebum")) return "oily_pores";
  if (v.includes("dry") || v.includes("dehydrat") || v.includes("flaky")) return "dryness";
  if (v.includes("uneven") || v.includes("tone") || v.includes("rosacea")) return "uneven_tone";
  return "acne";
}

function issueLabel(issueId: string): string {
  switch (issueId) {
    case "hyperpigmentation":
      return "Hyperpigmentation & Dark Spots";
    case "texture_scars":
      return "Texture & Acne Scars";
    case "aging":
      return "Aging & Sagging Skin";
    case "sensitivity":
      return "Sensitivity & Redness";
    case "oily_pores":
      return "Oily Skin & Enlarged Pores";
    case "dryness":
      return "Dry & Dehydrated Skin";
    case "uneven_tone":
      return "Uneven Skin Tone & Rosacea";
    default:
      return "Acne & Breakouts";
  }
}

function buildDetectedIssues(
  spots: Record<string, unknown>[],
  findings: Record<string, unknown>[],
  categoryMap: Map<string, Record<string, unknown>>,
): Record<string, unknown>[] {
  const byIssue = new Map<string, {
    issueId: string;
    label: string;
    severity: string;
    confidenceSum: number;
    confidenceCount: number;
    anchors: Record<string, unknown>[];
  }>();

  const push = (input: {
    rawId: string;
    severity: string;
    confidence?: number;
    anchor?: Record<string, unknown>;
    categoryName?: string;
  }) => {
    const issueId = canonicalIssueId(`${input.rawId} ${input.categoryName ?? ""}`);
    const item = byIssue.get(issueId) ?? {
      issueId,
      label: issueLabel(issueId),
      severity: "low",
      confidenceSum: 0,
      confidenceCount: 0,
      anchors: [],
    };

    if (severityWeight(input.severity) > severityWeight(item.severity)) {
      item.severity = input.severity;
    }
    if (typeof input.confidence === "number") {
      item.confidenceSum += input.confidence;
      item.confidenceCount += 1;
    }
    if (input.anchor) {
      item.anchors.push(input.anchor);
    }
    byIssue.set(issueId, item);
  };

  for (const spot of spots) {
    const categoryId = String(spot.categoryId ?? "");
    const cat = categoryMap.get(categoryId);
    push({
      rawId: categoryId,
      categoryName: String(cat?.name ?? ""),
      severity: String(spot.severity ?? "low"),
      confidence: Number(spot.confidence ?? 0),
      anchor: (spot.anchor as Record<string, unknown> | undefined),
    });
  }
  for (const finding of findings) {
    const categoryId = String(finding.categoryId ?? "");
    push({
      rawId: categoryId,
      categoryName: String(finding.categoryName ?? ""),
      severity: String(finding.severity ?? "low"),
      confidence: Number(finding.confidence ?? 0.7),
      anchor: (finding.anchor as Record<string, unknown> | undefined),
    });
  }

  const result = [...byIssue.values()].map((i) => ({
    issueId: i.issueId,
    label: i.label,
    severity: i.severity,
    confidence: i.confidenceCount > 0
      ? Number((i.confidenceSum / i.confidenceCount).toFixed(2))
      : 0.7,
    anchors: i.anchors.slice(0, 5),
  }));

  result.sort((a, b) => {
    const sev = severityWeight(String(b.severity)) - severityWeight(String(a.severity));
    if (sev !== 0) return sev;
    return Number(b.confidence) - Number(a.confidence);
  });
  return result;
}

function anchorXY(spot: Record<string, unknown>): { x: number; y: number } | null {
  const anchor = spot.anchor as Record<string, unknown> | undefined;
  if (!anchor) return null;
  const x = Number(anchor.x);
  const y = Number(anchor.y);
  if (!Number.isFinite(x) || !Number.isFinite(y)) return null;
  return { x, y };
}

function filterLowConfidenceSpots(
  spots: Record<string, unknown>[],
  minConfidence: number,
): Record<string, unknown>[] {
  return spots.filter((spot) => {
    const confidence = Number(spot.confidence ?? 1);
    return Number.isFinite(confidence) && confidence >= minConfidence;
  });
}

function dedupeSpotAnchors(
  spots: Record<string, unknown>[],
  minDistance: number,
): Record<string, unknown>[] {
  const kept: Record<string, unknown>[] = [];
  for (const spot of spots) {
    const a = anchorXY(spot);
    if (!a) {
      kept.push(spot);
      continue;
    }
    const tooClose = kept.some((other) => {
      const b = anchorXY(other);
      if (!b) return false;
      const dx = a.x - b.x;
      const dy = a.y - b.y;
      return Math.hypot(dx, dy) < minDistance;
    });
    if (!tooClose) kept.push(spot);
  }
  return kept;
}

function balanceLabelSides(spots: Record<string, unknown>[]): Record<string, unknown>[] {
  return spots.map((spot) => {
    const anchor = anchorXY(spot);
    if (!anchor) return spot;
    const side = anchor.x < 0.5 ? "left" : "right";
    return { ...spot, labelSide: side };
  });
}

function capSpotsBySeverity(
  spots: Record<string, unknown>[],
  maxCount: number,
): Record<string, unknown>[] {
  const sorted = [...spots].sort(
    (a, b) => severityWeight(String(b.severity)) - severityWeight(String(a.severity)),
  );
  return sorted.slice(0, maxCount);
}

function toNum(v: unknown, fallback = 0): number {
  if (typeof v === "number" && Number.isFinite(v)) return v;
  if (typeof v === "string" && v.trim() !== "") {
    const n = Number(v);
    if (Number.isFinite(n)) return n;
  }
  return fallback;
}

function toInt(v: unknown, fallback = 0): number {
  return Math.round(toNum(v, fallback));
}

function asRecord(v: unknown): Record<string, unknown> {
  if (v && typeof v === "object" && !Array.isArray(v)) {
    return v as Record<string, unknown>;
  }
  return {};
}

function asMapList(v: unknown): Record<string, unknown>[] {
  if (Array.isArray(v)) {
    return v
      .filter((x) => x && typeof x === "object" && !Array.isArray(x))
      .map((x) => x as Record<string, unknown>);
  }
  if (v && typeof v === "object" && !Array.isArray(v)) {
    return [v as Record<string, unknown>];
  }
  return [];
}

function asStringList(v: unknown): string[] {
  if (Array.isArray(v)) return v.map((x) => String(x).trim()).filter(Boolean);
  if (typeof v === "string" && v.trim()) return [v.trim()];
  return [];
}

function asNumList(v: unknown): number[] {
  if (!Array.isArray(v)) return [];
  return v.map((x) => toNum(x)).filter((n) => Number.isFinite(n));
}

function scoreLabelForRelationship(hint: string): string {
  switch (hint.toLowerCase()) {
    case "couple":
      return "Couple Similarity Score";
    case "friend":
      return "Friend Similarity Score";
    default:
      return "Sibling Similarity Score";
  }
}

function goldenRatingFor(index: number): string {
  if (index >= 85) return "Excellent";
  if (index >= 70) return "Good";
  if (index >= 55) return "Fair";
  return "Developing";
}

function goldenScoreOutOf20(absDelta: number): number {
  if (absDelta <= 0.015) return 20;
  if (absDelta <= 0.035) return 18;
  if (absDelta <= 0.055) return 16;
  if (absDelta <= 0.085) return 13;
  if (absDelta <= 0.12) return 10;
  if (absDelta <= 0.18) return 7;
  if (absDelta <= 0.25) return 4;
  return 2;
}

function ovalPoints(
  cx: number,
  cy: number,
  rx: number,
  ry: number,
  segments = 24,
): number[][] {
  return Array.from({ length: segments }, (_, i) => {
    const t = (i / segments) * 2 * Math.PI;
    return [cx + rx * Math.cos(t), cy + ry * Math.sin(t)];
  });
}

function mockTwoFaceContours(): Record<string, unknown>[] {
  return [
    {
      id: "face1",
      label: "Face 1",
      color: 0xe07a9a,
      contourPoints: ovalPoints(0.32, 0.48, 0.14, 0.20),
      center: { x: 0.32, y: 0.28 },
    },
    {
      id: "face2",
      label: "Face 2",
      color: 0x5b8def,
      contourPoints: ovalPoints(0.68, 0.48, 0.14, 0.20),
      center: { x: 0.68, y: 0.28 },
    },
  ];
}

function facesFromDetected(detectedFaces: unknown): Record<string, unknown>[] {
  const list = asMapList(detectedFaces);
  if (list.length >= 2) {
    return list.slice(0, 2).map((f, i) => ({
      id: f.id ?? `face${i + 1}`,
      label: f.label ?? `Face ${i + 1}`,
      color: toNum(f.color, i === 0 ? 0xe07a9a : 0x5b8def),
      contourPoints: f.contourPoints ?? ovalPoints(i === 0 ? 0.32 : 0.68, 0.48, 0.14, 0.20),
      center: f.center ?? { x: i === 0 ? 0.32 : 0.68, y: 0.28 },
    }));
  }
  return mockTwoFaceContours();
}

function clampScore(n: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, n));
}

function toPercent100(raw: unknown, fallback = 75): number {
  let n = toNum(raw, fallback);
  if (n > 0 && n <= 1) n *= 100;
  else if (n > 1 && n <= 10) n *= 10;
  return clampScore(Math.round(n), 0, 100);
}

function upliftPercent(score: number): number {
  const s = clampScore(Math.round(score), 0, 100);
  if (s <= 15) return clampScore(Math.round(32 + s * 0.75), 35, 45);
  if (s <= 50) return clampScore(Math.round(40 + s * 0.7), 0, 100);
  return clampScore(s + 5, 0, 100);
}

function toOutOf10(raw: unknown, fallback = 7.5): number {
  let n = toNum(raw, fallback);
  if (n > 10 && n <= 100) n /= 10;
  else if (n > 0 && n <= 1) n *= 10;
  return clampScore(Math.round(n * 10) / 10, 0, 10);
}

function upliftOutOf10(score: number): number {
  const pct = upliftPercent(Math.round(score * 10));
  return clampScore(Math.round(pct) / 10, 0, 10);
}

function markScoresFinalized(parsed: Record<string, unknown>): void {
  parsed.scoresFinalized = true;
}

const SYMMETRY_REGION_META: Record<
  string,
  {
    label: string;
    color: number;
    icon: string;
    anchor: { x: number; y: number };
    labelSide: string;
  }
> = {
  eyebrow: {
    label: "Eyebrows symmetry",
    color: 0x7b6fd6,
    icon: "star",
    anchor: { x: 0.28, y: 0.26 },
    labelSide: "left",
  },
  eyes: {
    label: "Eyes symmetry",
    color: 0x5b8def,
    icon: "star",
    anchor: { x: 0.72, y: 0.36 },
    labelSide: "right",
  },
  nose: {
    label: "Nose symmetry",
    color: 0x4caf7a,
    icon: "check",
    anchor: { x: 0.28, y: 0.48 },
    labelSide: "left",
  },
  mouth: {
    label: "Mouth symmetry",
    color: 0xe07a9a,
    icon: "heart",
    anchor: { x: 0.72, y: 0.56 },
    labelSide: "right",
  },
  lip: {
    label: "Lips symmetry",
    color: 0xe07a9a,
    icon: "heart",
    anchor: { x: 0.30, y: 0.66 },
    labelSide: "left",
  },
  cheeks: {
    label: "Cheeks symmetry",
    color: 0xe8a04c,
    icon: "circle",
    anchor: { x: 0.72, y: 0.74 },
    labelSide: "right",
  },
  jaw: {
    label: "Jaw symmetry",
    color: 0xc5a373,
    icon: "check",
    anchor: { x: 0.28, y: 0.80 },
    labelSide: "left",
  },
};

const SHOWDOWN_FIRST_NAMES = [
  "Bella",
  "Loveth",
  "Amara",
  "Sofia",
  "Mia",
  "Zara",
  "Luna",
  "Aisha",
  "Chloe",
  "Nina",
  "Emma",
  "Grace",
  "Priya",
  "Layla",
  "Ruby",
];

function pickShowdownNames(count: number): string[] {
  const pool = [...SHOWDOWN_FIRST_NAMES].sort(() => Math.random() - 0.5);
  return pool.slice(0, count);
}

function normalizeFacialSymmetry(parsed: Record<string, unknown>): Record<string, unknown> {
  const guidesIn = asRecord(parsed.guides);
  parsed.guides = {
    verticalCenter: toNum(guidesIn.verticalCenter, 0.5),
    verticalSideLines: asNumList(guidesIn.verticalSideLines).length >= 2
      ? asNumList(guidesIn.verticalSideLines)
      : [0.35, 0.65],
    horizontalLines: asNumList(guidesIn.horizontalLines).length >= 3
      ? asNumList(guidesIn.horizontalLines)
      : [0.18, 0.28, 0.38, 0.52, 0.64, 0.78, 0.88],
  };

  const baseOverallRaw = parseNumericScore(
    parsed.overallSymmetryScore ?? parsed.overallPercent ?? parsed.overallScore,
    78,
  );

  let rawRegions: unknown = parsed.regions;
  if (rawRegions && typeof rawRegions === "object" && !Array.isArray(rawRegions)) {
    rawRegions = Object.entries(rawRegions as Record<string, unknown>).map(
      ([name, score]) => ({ name, score }),
    );
  }
  const regionRows = asMapList(rawRegions);

  const rawRegionScores: Record<string, number> = {};
  for (const row of regionRows) {
    const nameKey = String(row.id ?? row.name ?? "").toLowerCase();
    const metaKey =
      Object.keys(SYMMETRY_REGION_META).find((k) => nameKey.includes(k)) ?? "";
    if (!metaKey || metaKey === "jaw" || metaKey === "lip") continue;
    const defaultBase = SYMMETRY_REGION_DEFAULTS[metaKey] ?? baseOverallRaw;
    rawRegionScores[metaKey] = parseNumericScore(
      row.percent ?? row.score ?? row.value,
      defaultBase,
    );
  }

  if (Object.keys(rawRegionScores).length === 0) {
    for (const [id, base] of Object.entries(SYMMETRY_REGION_DEFAULTS)) {
      rawRegionScores[id] = base;
    }
  }

  const spreadRegionRaw = ensureSpread(rawRegionScores, SYMMETRY_REGION_OFFSETS);
  const regions: Record<string, unknown>[] = [];

  for (const [metaKey, rawPercent] of Object.entries(spreadRegionRaw)) {
    const meta = SYMMETRY_REGION_META[metaKey];
    if (!meta) continue;
    const row = regionRows.find((r) => {
      const nk = String(r.id ?? r.name ?? "").toLowerCase();
      return nk.includes(metaKey);
    });
    const anchorIn = row ? asRecord(row.anchor) : {};
    regions.push({
      id: metaKey,
      label: String(row?.label ?? meta.label),
      percent: displayBoost(rawPercent),
      color: toNum(row?.color, meta.color),
      icon: String(row?.icon ?? meta.icon),
      anchor: anchorIn.x != null ? row?.anchor : meta.anchor,
      labelSide: String(row?.labelSide ?? meta.labelSide),
    });
  }

  const regionAvgRaw = Math.round(
    Object.values(spreadRegionRaw).reduce((a, b) => a + b, 0) /
      Object.values(spreadRegionRaw).length,
  );

  const subKeys = [
    "beauty",
    "cuteness",
    "skinSmoothness",
    "handsomeness",
    "faceShape",
    "facialSymmetry",
  ];
  const subIn = asRecord(parsed.subscores);
  const rawSubs: Record<string, number> = {};
  for (const key of subKeys) {
    rawSubs[key] = parseNumericScore(subIn[key], regionAvgRaw);
  }
  const spreadSubs = ensureSpread(rawSubs, SYMMETRY_SUB_OFFSETS);
  const subAvgRaw = deriveOverall(spreadSubs, SYMMETRY_SUB_WEIGHTS);

  const overallRaw = Math.round((regionAvgRaw + subAvgRaw) / 2);
  const overallPercent = displayBoost(overallRaw);

  parsed.regions = regions;
  parsed.overallSymmetryScore = overallPercent;
  parsed.overallPercent = overallPercent;
  parsed.tierLabel = symmetryTierFor(overallPercent);
  parsed.subscores = boostScoreMap(spreadSubs);
  parsed.annotations = [];
  markScoresFinalized(parsed);

  return parsed;
}

function normalizeFaceBeauty(parsed: Record<string, unknown>): Record<string, unknown> {
  const subKeys = [
    "symmetry",
    "featureBalance",
    "skinQuality",
    "youthfulCues",
    "overallBeauty",
  ];
  const subIn = asRecord(parsed.subscores);
  const rawSubs: Record<string, number> = {};
  for (const key of subKeys) {
    rawSubs[key] = parseNumericScore(subIn[key], 75);
  }
  const spreadSubs = ensureSpread(rawSubs, FACE_BEAUTY_OFFSETS);
  const derivedRaw = deriveOverall(spreadSubs, FACE_BEAUTY_WEIGHTS);
  const modelRaw = parseNumericScore(
    parsed.beautyScore ?? parsed.overallScore,
    derivedRaw,
  );
  const overallRaw = Math.abs(modelRaw - derivedRaw) > 12 ? derivedRaw : modelRaw;
  const beautyScore = displayBoost(overallRaw);

  parsed.beautyScore = beautyScore;
  parsed.ratingLabel = beautyHarmonyTierFor(beautyScore);
  parsed.subscores = boostScoreMap(spreadSubs);

  const annotations = asMapList(parsed.annotations).map((row, i) => {
    const anchorIn = asRecord(row.anchor);
    const sides = ["left", "right", "top", "bottom"];
    return {
      text: String(row.text ?? "Harmonious facial proportions"),
      anchor: anchorIn.x != null ? row.anchor : { x: 0.5, y: 0.22 + i * 0.14 },
      labelSide: String(row.labelSide ?? sides[i % sides.length]),
    };
  });
  parsed.annotations = annotations.length > 0
    ? annotations.slice(0, 5)
    : [
      {
        text: "Facial structure appears well-defined",
        anchor: { x: 0.28, y: 0.30 },
        labelSide: "left",
      },
      {
        text: "Feature balance looks harmonious",
        anchor: { x: 0.72, y: 0.48 },
        labelSide: "right",
      },
      {
        text: "Skin tone reads even and healthy",
        anchor: { x: 0.30, y: 0.68 },
        labelSide: "left",
      },
    ];

  markScoresFinalized(parsed);
  return parsed;
}

function defaultFaceReadingLandmarks(): { x: number; y: number }[] {
  return [
    { x: 0.28, y: 0.28 },
    { x: 0.38, y: 0.25 },
    { x: 0.62, y: 0.25 },
    { x: 0.72, y: 0.28 },
    { x: 0.32, y: 0.38 },
    { x: 0.40, y: 0.38 },
    { x: 0.60, y: 0.38 },
    { x: 0.68, y: 0.38 },
    { x: 0.50, y: 0.30 },
    { x: 0.50, y: 0.52 },
    { x: 0.44, y: 0.54 },
    { x: 0.56, y: 0.54 },
    { x: 0.38, y: 0.64 },
    { x: 0.50, y: 0.62 },
    { x: 0.62, y: 0.64 },
    { x: 0.50, y: 0.70 },
    { x: 0.24, y: 0.58 },
    { x: 0.50, y: 0.84 },
    { x: 0.76, y: 0.58 },
    { x: 0.22, y: 0.42 },
    { x: 0.78, y: 0.42 },
  ];
}

function defaultFaceReadingMeshConnections(): number[][] {
  return [
    [0, 1], [1, 2], [2, 3],
    [4, 5], [6, 7], [5, 6],
    [8, 9], [9, 10], [9, 11], [10, 11],
    [12, 13], [13, 14], [14, 15], [12, 15],
    [16, 17], [17, 18], [19, 16], [20, 18],
    [1, 8], [2, 8],
    [5, 9], [6, 9],
    [10, 12], [11, 14],
  ];
}

function normalizeFaceReadingLandmarks(raw: unknown): { x: number; y: number }[] {
  const points: { x: number; y: number }[] = [];

  const addPoint = (item: unknown) => {
    if (!item || typeof item !== "object") return;
    const pt = item as Record<string, unknown>;
    const x = toNum(pt.x, Number.NaN);
    const y = toNum(pt.y, Number.NaN);
    if (!Number.isFinite(x) || !Number.isFinite(y)) return;
    if (x < 0 || x > 1 || y < 0 || y > 1) return;
    points.push({ x, y });
  };

  const addFromValue = (value: unknown) => {
    if (Array.isArray(value)) {
      for (const item of value) addFromValue(item);
      return;
    }
    addPoint(value);
  };

  if (Array.isArray(raw)) {
    for (const item of raw) addFromValue(item);
  } else if (raw && typeof raw === "object") {
    for (const value of Object.values(raw as Record<string, unknown>)) {
      addFromValue(value);
    }
  }

  return points.length >= 4 ? points : defaultFaceReadingLandmarks();
}

function normalizeFaceReadingMesh(raw: unknown): number[][] {
  if (!Array.isArray(raw) || raw.length === 0) {
    return defaultFaceReadingMeshConnections();
  }
  const pairs: number[][] = [];
  for (const row of raw) {
    if (!Array.isArray(row) || row.length < 2) continue;
    const a = toInt(row[0], -1);
    const b = toInt(row[1], -1);
    if (a < 0 || b < 0) continue;
    pairs.push([a, b]);
  }
  return pairs.length > 0 ? pairs : defaultFaceReadingMeshConnections();
}

function normalizeFaceReading(parsed: Record<string, unknown>): Record<string, unknown> {
  const appearanceKeys = [
    "beauty",
    "handsomeness",
    "cuteness",
    "faceShape",
    "facialSymmetry",
    "skinSmoothness",
  ];
  const traitKeys = ["funFactor", "intelligence", "confidence", "credibility"];

  const appearanceIn = asRecord(parsed.appearanceScores);
  const traitIn = asRecord(parsed.traitScores);

  const rawAppearance: Record<string, number> = {};
  for (const key of appearanceKeys) {
    rawAppearance[key] = parseNumericScore(appearanceIn[key], 75);
  }
  const spreadAppearance = ensureSpread(rawAppearance, APPEARANCE_OFFSETS);
  const derivedRaw = deriveOverall(spreadAppearance, APPEARANCE_WEIGHTS);
  const modelPercent = parseNumericScore(parsed.overallScore, derivedRaw);
  const overallRaw = Math.abs(modelPercent - derivedRaw) > 12 ? derivedRaw : modelPercent;
  const overallScore = displayBoostOutOf10(overallRaw / 10);

  parsed.overallScore = overallScore;
  parsed.overallPercent = Math.round(overallScore * 10);
  parsed.tierLabel = attractivenessTierFor(overallScore);
  parsed.subtitle = String(
    parsed.subtitle ??
      "Proportion-based harmony reading — for wellness inspiration, not medical advice.",
  );
  parsed.facialAge = clampScore(
    toInt(parsed.facialAge, Math.round(22 + overallScore)),
    18,
    45,
  );

  const rawTraits: Record<string, number> = {};
  for (const key of traitKeys) {
    rawTraits[key] = parseNumericScore(traitIn[key], overallRaw - 5);
  }
  const spreadTraits = ensureSpread(rawTraits, TRAIT_OFFSETS);

  parsed.appearanceScores = boostScoreMap(spreadAppearance);
  parsed.traitScores = boostScoreMap(spreadTraits);

  const boxIn = asRecord(parsed.faceBox);
  const topLeft = asRecord(boxIn.topLeft);
  const bottomRight = asRecord(boxIn.bottomRight);
  if (Object.keys(topLeft).length > 0 && Object.keys(bottomRight).length > 0) {
    const x1 = clampScore(toNum(topLeft.x, 0.21), 0, 1);
    const y1 = clampScore(toNum(topLeft.y, 0.18), 0, 1);
    const x2 = clampScore(toNum(bottomRight.x, x1 + 0.58), 0, 1);
    const y2 = clampScore(toNum(bottomRight.y, y1 + 0.48), 0, 1);
    parsed.faceBox = {
      x: clampScore(x1, 0, 0.75),
      y: clampScore(y1, 0, 0.75),
      width: clampScore(Math.abs(x2 - x1), 0.2, 0.85),
      height: clampScore(Math.abs(y2 - y1), 0.2, 0.85),
    };
  } else {
    parsed.faceBox = {
      x: clampScore(toNum(boxIn.x, 0.21), 0, 0.75),
      y: clampScore(toNum(boxIn.y, 0.18), 0, 0.75),
      width: clampScore(toNum(boxIn.width, 0.58), 0.2, 0.85),
      height: clampScore(toNum(boxIn.height, 0.48), 0.2, 0.85),
    };
  }

  parsed.landmarks = normalizeFaceReadingLandmarks(parsed.landmarks);
  parsed.meshConnections = normalizeFaceReadingMesh(parsed.meshConnections);
  markScoresFinalized(parsed);

  return parsed;
}

function normalizeShowdown(parsed: Record<string, unknown>): Record<string, unknown> {
  const yourScore = upliftOutOf10(toOutOf10(parsed.yourScore, 8.0));
  parsed.yourScore = yourScore;
  parsed.averageScore = upliftOutOf10(toOutOf10(parsed.averageScore, 7.2));
  parsed.rankPosition = toInt(parsed.rankPosition, 2);
  parsed.totalParticipants = Math.max(toInt(parsed.totalParticipants, 100), 10);

  const topPercent = Math.max(
    5,
    Math.ceil((Number(parsed.rankPosition) / Number(parsed.totalParticipants)) * 100),
  );
  parsed.rankLabel = String(parsed.rankLabel ?? `Top ${topPercent}%`);
  parsed.engagementNote = String(
    parsed.engagementNote ??
      "Complete challenges and scan regularly to climb the community board.",
  );

  const podium = asMapList(parsed.podium).map((row, i) => ({
    rank: toInt(row.rank, i + 1),
    displayName: String(row.displayName ?? row.name ?? pickShowdownNames(1)[0]),
    name: String(row.name ?? row.displayName ?? pickShowdownNames(1)[0]),
    score: upliftOutOf10(toOutOf10(row.score, yourScore + 0.2)),
    isSimulated: row.isSimulated ?? true,
  }));
  parsed.podium = podium;
  return parsed;
}

function normalizeFacialResemblance(
  parsed: Record<string, unknown>,
  detectedFaces: unknown,
): Record<string, unknown> {
  const similarity = toInt(parsed.similarity, 78);
  const relationshipHint = String(
    parsed.relationshipHint ?? parsed.relationship ?? "sibling",
  );
  parsed.similarity = similarity;
  parsed.scoreLabel = String(
    parsed.scoreLabel ?? scoreLabelForRelationship(relationshipHint),
  );
  parsed.relationshipHint = relationshipHint;
  parsed.sharedTraits = asStringList(parsed.sharedTraits).length > 0
    ? asStringList(parsed.sharedTraits)
    : [
      "Similar face shape",
      "Aligned jawline contour",
      "Comparable cheekbone height",
    ];
  parsed.contourComparison = String(
    parsed.contourComparison ??
      parsed.note ??
      "Both faces show similar outer contours and jawline alignment.",
  );
  parsed.explanation = String(
    parsed.explanation ??
      parsed.note ??
      "The score reflects how closely the outer face contours align.",
  );
  parsed.faces = facesFromDetected(detectedFaces);
  return parsed;
}

function defaultGoldenLandmarks(): Record<string, { x: number; y: number }> {
  return {
    hairline: { x: 0.50, y: 0.18 },
    chin: { x: 0.50, y: 0.88 },
    faceWidthLeft: { x: 0.22, y: 0.48 },
    faceWidthRight: { x: 0.78, y: 0.48 },
    eyeInnerL: { x: 0.40, y: 0.38 },
    eyeOuterL: { x: 0.32, y: 0.38 },
    eyeInnerR: { x: 0.60, y: 0.38 },
    eyeOuterR: { x: 0.68, y: 0.38 },
    noseBridge: { x: 0.50, y: 0.30 },
    noseWingL: { x: 0.44, y: 0.54 },
    noseWingR: { x: 0.56, y: 0.54 },
    mouthCornerL: { x: 0.38, y: 0.64 },
    mouthCornerR: { x: 0.62, y: 0.64 },
    philtrum: { x: 0.50, y: 0.58 },
  };
}

function normalizeGoldenMeasurement(
  row: Record<string, unknown>,
  landmarks: Record<string, { x: number; y: number }>,
  fallbackId: string,
): Record<string, unknown> {
  const id = String(row.id ?? fallbackId);
  const ideal = toNum(row.ideal, 1.618);
  const ratio = toNum(row.ratio, ideal);
  const delta = toNum(row.delta, ratio - ideal);
  const absDelta = Math.abs(delta);
  const scoreOutOf20 = toInt(row.scoreOutOf20, goldenScoreOutOf20(absDelta));
  const pass = row.pass === true || absDelta <= 0.055;
  const from = asRecord(row.from);
  const to = asRecord(row.to);
  const defaultFrom = landmarks.hairline ?? { x: 0.5, y: 0.2 };
  const defaultTo = landmarks.chin ?? { x: 0.5, y: 0.85 };

  return {
    id,
    name: String(row.name ?? id),
    ratio: Number(ratio.toFixed(3)),
    ideal,
    delta: Number(delta.toFixed(3)),
    scoreOutOf20,
    pass,
    lineType: String(row.lineType ?? "horizontal"),
    from: from.x != null ? from : defaultFrom,
    to: to.x != null ? to : defaultTo,
    calloutAnchor: asRecord(row.calloutAnchor).x != null
      ? row.calloutAnchor
      : { x: 0.12, y: 0.42 },
    labelSide: String(row.labelSide ?? "left"),
    highlightBracket: row.highlightBracket === true || !pass,
  };
}

function normalizeGoldenRatio(
  parsed: Record<string, unknown>,
  _detectedFaces: unknown,
): Record<string, unknown> {
  const idealPhi = toNum(parsed.idealPhi, 1.618);
  let goldenRatioIndex = toInt(
    parsed.goldenRatioIndex ?? parsed.harmonyPercent,
    0,
  );
  let overallScore = toNum(parsed.overallScore, 0);
  if (goldenRatioIndex <= 0 && overallScore > 0) {
    goldenRatioIndex = Math.min(100, Math.max(0, Math.round(overallScore * 10)));
  }
  if (overallScore <= 0 && goldenRatioIndex > 0) {
    overallScore = Number((goldenRatioIndex / 10).toFixed(1));
  }
  if (goldenRatioIndex <= 0) goldenRatioIndex = 72;
  if (overallScore <= 0) overallScore = Number((goldenRatioIndex / 10).toFixed(1));

  const landmarksRaw = asRecord(parsed.landmarks);
  const landmarks = defaultGoldenLandmarks();
  for (const [key, val] of Object.entries(landmarksRaw)) {
    const pt = asRecord(val);
    if (pt.x != null && pt.y != null) {
      landmarks[key] = { x: toNum(pt.x, 0.5), y: toNum(pt.y, 0.5) };
    }
  }

  let measurementRows = parsed.measurements;
  if (measurementRows && typeof measurementRows === "object" && !Array.isArray(measurementRows)) {
    measurementRows = Object.entries(measurementRows as Record<string, unknown>).map(
      ([id, val]) => ({ id, ...(asRecord(val)) }),
    );
  }
  let measurements = asMapList(measurementRows).map((row, i) =>
    normalizeGoldenMeasurement(row, landmarks, `metric_${i + 1}`)
  );

  if (measurements.length === 0) {
    const defs = [
      { id: "faceLengthWidth", name: "Face Length : Face Width", ratio: 1.62, ideal: idealPhi, from: landmarks.hairline, to: landmarks.chin, labelSide: "left" },
      { id: "eyeDistanceFaceWidth", name: "Eye Distance : Face Width", ratio: 0.26, ideal: 0.262, from: landmarks.eyeInnerL, to: landmarks.eyeInnerR, labelSide: "right" },
      { id: "mouthWidthNoseWidth", name: "Mouth Width : Nose Width", ratio: 1.61, ideal: idealPhi, from: landmarks.mouthCornerL, to: landmarks.mouthCornerR, labelSide: "right" },
    ];
    measurements = defs.map((d) => normalizeGoldenMeasurement(d, landmarks, d.id));
  }

  const scoreSum = measurements.reduce(
    (sum, m) => sum + toInt(m.scoreOutOf20, 0),
    0,
  );
  if (goldenRatioIndex <= 0 && measurements.length > 0) {
    goldenRatioIndex = Math.round((scoreSum / measurements.length) * 5);
  }
  overallScore = Number((goldenRatioIndex / 10).toFixed(1));

  parsed.idealPhi = idealPhi;
  const upliftedIndex = upliftPercent(goldenRatioIndex);
  parsed.goldenRatioIndex = upliftedIndex;
  parsed.harmonyPercent = upliftedIndex;
  parsed.overallScore = upliftOutOf10(upliftedIndex / 10);
  parsed.ratingLabel = String(parsed.ratingLabel ?? goldenRatingFor(upliftedIndex));
  parsed.landmarks = landmarks;
  parsed.measurements = measurements;
  parsed.deviations = asStringList(parsed.deviations).length > 0
    ? asStringList(parsed.deviations)
    : measurements.filter((m) => m.pass !== true).map((m) => String(m.name));
  return parsed;
}

function normalizeCelebrityPayload(parsed: Record<string, unknown>): Record<string, unknown> {
  const raw = parsed.matches;
  const rows = Array.isArray(raw) ? raw : [];
  const draft: { name: string; rawPercent: number; traits: string[]; why: string; imageUrl: unknown }[] = [];

  for (const row of rows) {
    if (!row || typeof row !== "object") continue;
    const item = row as Record<string, unknown>;
    const name = String(item.name ?? item.celebrityName ?? "").trim();
    if (!name) continue;

    let traits: string[] = [];
    if (Array.isArray(item.traits)) {
      traits = item.traits.map((t) => String(t).trim()).filter(Boolean).slice(0, 4);
    } else if (Array.isArray(item.sharedFeatures)) {
      traits = item.sharedFeatures.map((t) => String(t).trim()).filter(Boolean).slice(0, 4);
    }

    const why = String(item.why ?? item.reason ?? "").trim()
      || (traits.length > 0 ? traits.join(", ") : "Similar facial proportions and features.");

    draft.push({
      name,
      rawPercent: parseNumericScore(item.percent ?? item.similarity, 75),
      traits,
      why,
      imageUrl: item.imageUrl ?? null,
    });
  }

  draft.sort((a, b) => b.rawPercent - a.rawPercent);
  const staggered = ensureCelebritySpread(draft.map((d) => d.rawPercent));

  const matches: Record<string, unknown>[] = draft.map((item, i) => ({
    name: item.name,
    percent: clampScore(displayBoost(staggered[i] ?? item.rawPercent), 62, 98),
    traits: item.traits,
    why: item.why,
    imageUrl: item.imageUrl,
  }));

  matches.sort((a, b) => Number(b.percent) - Number(a.percent));

  if (matches.length === 0) {
    console.warn("Celebrity payload had no valid matches after normalization");
  }

  parsed.matches = matches.slice(0, 5);
  if (parsed.detectedGender == null) {
    parsed.detectedGender = "unknown";
  }
  parsed.disclaimer =
    "Playful style resemblance for entertainment — not biometric identification.";
  markScoresFinalized(parsed);
  return parsed;
}

type ShowdownLeaderRow = {
  user_id: string;
  display_name: string;
  showdown_avatar_url: string | null;
  engagement_score: number;
  beauty_score_avg: number;
};

async function fetchShowdownLeaderboard(
  admin: ReturnType<typeof createClient>,
): Promise<ShowdownLeaderRow[]> {
  const { data, error } = await admin.rpc("get_showdown_leaderboard", {
    p_limit: 200,
  });
  if (error) {
    console.warn("get_showdown_leaderboard failed", error);
    return [];
  }
  return (data ?? []) as ShowdownLeaderRow[];
}

async function resolveShowdownAvatarUrl(
  seed: string,
  admin: ReturnType<typeof createClient>,
  openaiKey: string,
  supabaseUrl: string,
  promptName: string,
): Promise<string | null> {
  const slug = celebrityPortraitSlug(`showdown-${seed}`);
  if (!slug) return null;
  const storagePath = `${slug}.png`;
  const bucket = "showdown-avatars";

  const { data: existing } = await admin.storage.from(bucket).download(storagePath);
  if (existing) {
    return publicStorageUrl(supabaseUrl, bucket, storagePath);
  }

  let imageBytes = await generatePortraitImage(
    openaiKey,
    `Friendly beauty app member portrait of ${promptName}, soft neutral background, photorealistic headshot, facing camera, warm smile, no text`,
  );
  if (!imageBytes) {
    imageBytes = await generatePortraitImage(
      openaiKey,
      `Friendly beauty app member portrait of ${promptName}, soft neutral background, photorealistic headshot, facing camera, warm smile, no text`,
    );
  }
  if (!imageBytes) return null;

  const { error } = await admin.storage.from(bucket).upload(storagePath, imageBytes, {
    contentType: "image/png",
    upsert: true,
  });
  if (error) {
    console.warn(`showdown avatar upload failed for ${seed}`, error);
    return null;
  }

  return publicStorageUrl(supabaseUrl, bucket, storagePath);
}

async function enrichPodiumAvatars(
  podium: Record<string, unknown>[],
  admin: ReturnType<typeof createClient>,
  openaiKey: string,
  supabaseUrl: string,
): Promise<Record<string, unknown>[]> {
  return await Promise.all(
    podium.map(async (entry) => {
      if (entry.avatarUrl || entry.isCurrentUser) return entry;
      const name = String(entry.displayName ?? entry.name ?? "Member");
      const avatarUrl = await resolveShowdownAvatarUrl(
        name,
        admin,
        openaiKey,
        supabaseUrl,
        name,
      );
      return avatarUrl ? { ...entry, avatarUrl, imageSource: "generated" } : entry;
    }),
  );
}

async function buildSimulatedShowdownPodium(
  parsed: Record<string, unknown>,
  admin: ReturnType<typeof createClient>,
  openaiKey: string,
  supabaseUrl: string,
): Promise<Record<string, unknown>> {
  const yourScore = toNum(parsed.yourScore, 8);
  const names = pickShowdownNames(3);
  const totalParticipants = Math.max(toInt(parsed.totalParticipants, 100), 50);

  const podium: Record<string, unknown>[] = [
    {
      rank: 1,
      displayName: names[0],
      name: names[0],
      score: upliftOutOf10(yourScore + 0.35),
      isSimulated: true,
    },
    {
      rank: 2,
      displayName: names[1],
      name: names[1],
      score: upliftOutOf10(yourScore + 0.12),
      isSimulated: true,
    },
    {
      rank: 3,
      displayName: names[2],
      name: names[2],
      score: upliftOutOf10(yourScore - 0.08),
      isSimulated: true,
    },
  ];

  parsed.podium = await enrichPodiumAvatars(podium, admin, openaiKey, supabaseUrl);
  parsed.rankPosition = Math.max(2, toInt(parsed.rankPosition, 2));
  parsed.totalParticipants = totalParticipants;
  const topPercent = Math.max(
    5,
    Math.ceil((Number(parsed.rankPosition) / totalParticipants) * 100),
  );
  parsed.rankLabel = `Top ${topPercent}%`;
  parsed.engagementNote =
    "You're climbing the board — keep scanning and finishing challenge days to pass more members.";
  return parsed;
}

async function buildRealShowdownPodium(
  parsed: Record<string, unknown>,
  leaderboard: ShowdownLeaderRow[],
  userId: string,
  admin: ReturnType<typeof createClient>,
  openaiKey: string,
  supabaseUrl: string,
): Promise<Record<string, unknown>> {
  const yourScore = toNum(parsed.yourScore, 8);
  const sorted = [...leaderboard].sort(
    (a, b) =>
      Number(b.engagement_score) - Number(a.engagement_score) ||
      Number(b.beauty_score_avg) - Number(a.beauty_score_avg),
  );

  let rankPosition = sorted.findIndex((row) => row.user_id === userId) + 1;
  if (rankPosition <= 0) {
    rankPosition = Math.min(sorted.length + 1, Math.max(2, toInt(parsed.rankPosition, 2)));
  }

  const topThree = sorted.slice(0, 3);
  const podium: Record<string, unknown>[] = await Promise.all(
    topThree.map(async (row, i) => {
      let avatarUrl = row.showdown_avatar_url;
      if (!avatarUrl && row.user_id !== userId) {
        avatarUrl = await resolveShowdownAvatarUrl(
          row.user_id,
          admin,
          openaiKey,
          supabaseUrl,
          row.display_name,
        );
        if (avatarUrl) {
          await admin.from("profiles").update({ showdown_avatar_url: avatarUrl }).eq(
            "id",
            row.user_id,
          );
        }
      }
      return {
        rank: i + 1,
        displayName: row.display_name,
        name: row.display_name,
        score: upliftOutOf10(Number(row.beauty_score_avg) || yourScore + 0.2 - i * 0.1),
        avatarUrl,
        isSimulated: false,
        isCurrentUser: row.user_id === userId,
      };
    }),
  );

  parsed.podium = podium;
  parsed.rankPosition = rankPosition;
  parsed.totalParticipants = Math.max(sorted.length, 5);
  const topPercent = Math.max(
    5,
    Math.ceil((rankPosition / Number(parsed.totalParticipants)) * 100),
  );
  parsed.rankLabel = `Top ${topPercent}%`;
  parsed.engagementNote =
    "Rankings reflect scans plus challenge activity across the Verified Glam community.";
  return parsed;
}

async function enrichShowdown(
  parsed: Record<string, unknown>,
  admin: ReturnType<typeof createClient>,
  openaiKey: string,
  supabaseUrl: string,
  userId: string,
): Promise<Record<string, unknown>> {
  const normalized = normalizeShowdown(parsed);
  const leaderboard = await fetchShowdownLeaderboard(admin);

  if (leaderboard.length >= 5) {
    return await buildRealShowdownPodium(
      normalized,
      leaderboard,
      userId,
      admin,
      openaiKey,
      supabaseUrl,
    );
  }

  return await buildSimulatedShowdownPodium(
    normalized,
    admin,
    openaiKey,
    supabaseUrl,
  );
}

async function enrichCelebrityMatches(
  parsed: Record<string, unknown>,
  admin: ReturnType<typeof createClient>,
  openaiKey: string,
  supabaseUrl: string,
): Promise<Record<string, unknown>> {
  const withTmdb = await enrichCelebrityMatchesWithTmdb(parsed);
  return await enrichCelebrityMatchesWithGeneratedPortraits(
    withTmdb,
    admin,
    openaiKey,
    supabaseUrl,
  );
}

function celebrityPortraitSlug(name: string): string {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 80);
}

function publicStorageUrl(
  supabaseUrl: string,
  bucket: string,
  path: string,
): string {
  return `${supabaseUrl}/storage/v1/object/public/${bucket}/${path}`;
}

async function resolveCelebrityPortraitUrl(
  name: string,
  admin: ReturnType<typeof createClient>,
  openaiKey: string,
  supabaseUrl: string,
): Promise<string | null> {
  const slug = celebrityPortraitSlug(name);
  if (!slug) return null;
  const storagePath = `${slug}.png`;
  const bucket = "celebrity-match-portraits";

  const { data: existing } = await admin.storage.from(bucket).download(storagePath);
  if (existing) {
    return publicStorageUrl(supabaseUrl, bucket, storagePath);
  }

  let imageBytes = await generatePortraitImage(
    openaiKey,
    `Professional studio headshot portrait photograph resembling ${name}, neutral soft background, photorealistic, facing camera, no text, no watermark`,
  );
  if (!imageBytes) {
    imageBytes = await generatePortraitImage(
      openaiKey,
      `Professional studio headshot portrait photograph resembling ${name}, neutral soft background, photorealistic, facing camera, no text, no watermark`,
    );
  }
  if (!imageBytes) return null;

  const { error } = await admin.storage.from(bucket).upload(storagePath, imageBytes, {
    contentType: "image/png",
    upsert: true,
  });
  if (error) {
    console.warn(`celebrity portrait upload failed for ${name}`, error);
    return null;
  }

  return publicStorageUrl(supabaseUrl, bucket, storagePath);
}

async function generatePortraitImage(
  openaiKey: string,
  prompt: string,
): Promise<Uint8Array | null> {
  const res = await fetch("https://api.openai.com/v1/images/generations", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${openaiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "dall-e-2",
      prompt,
      n: 1,
      size: "256x256",
      response_format: "b64_json",
    }),
  });
  if (!res.ok) {
    console.warn("OpenAI portrait generation failed", await res.text());
    return null;
  }
  const json = await res.json();
  const b64 = json.data?.[0]?.b64_json as string | undefined;
  if (!b64) return null;
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes;
}

async function enrichCelebrityMatchesWithGeneratedPortraits(
  parsed: Record<string, unknown>,
  admin: ReturnType<typeof createClient>,
  openaiKey: string,
  supabaseUrl: string,
): Promise<Record<string, unknown>> {
  const matches = (parsed.matches as Record<string, unknown>[]) ?? [];
  if (matches.length === 0) return parsed;

  const enriched = await Promise.all(
    matches.map(async (match) => {
      if (match.imageUrl) return match;
      const name = String(match.name ?? "").trim();
      if (!name) return match;
      try {
        let imageUrl = await resolveCelebrityPortraitUrl(
          name,
          admin,
          openaiKey,
          supabaseUrl,
        );
        if (!imageUrl) {
          imageUrl = await resolveCelebrityPortraitUrl(
            name,
            admin,
            openaiKey,
            supabaseUrl,
          );
        }
        if (!imageUrl) {
          console.warn(`Celebrity portrait missing after retries for ${name}`);
          return match;
        }
        return { ...match, imageUrl, imageSource: "generated" };
      } catch (e) {
        console.warn(`Portrait fallback failed for ${name}`, e);
        return match;
      }
    }),
  );

  parsed.matches = enriched;
  return parsed;
}

async function enrichCelebrityMatchesWithTmdb(
  parsed: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  const apiKey = Deno.env.get("TMDB_API_KEY")?.trim();
  const matches = (parsed.matches as Record<string, unknown>[]) ?? [];
  if (!apiKey || matches.length === 0) return parsed;

  const enriched = await Promise.all(
    matches.map(async (match) => {
      if (match.imageUrl) return match;
      const name = String(match.name ?? "");
      if (!name) return match;
      try {
        const url =
          `https://api.themoviedb.org/3/search/person?api_key=${encodeURIComponent(apiKey)}&query=${encodeURIComponent(name)}&include_adult=false`;
        const res = await fetch(url);
        if (!res.ok) return match;
        const data = await res.json();
        const person = data.results?.[0];
        const profilePath = person?.profile_path as string | undefined;
        if (!profilePath) return match;
        return {
          ...match,
          imageUrl: `https://image.tmdb.org/t/p/w185${profilePath}`,
          tmdbId: person.id,
        };
      } catch (e) {
        console.warn(`TMDB lookup failed for ${name}`, e);
        return match;
      }
    }),
  );

  parsed.matches = enriched;
  return parsed;
}
