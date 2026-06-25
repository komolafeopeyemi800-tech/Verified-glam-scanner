import { createClient } from "https://esm.sh/@supabase/supabase-js@2.48.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const BATCH_SIZE = 50;
const DAILY_CAP = 2;

const KIND_PRIORITY: Record<string, number> = {
  completion: 4,
  unlock: 3,
  streak: 2,
  evening: 2,
  reminder: 1,
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    if (!supabaseUrl || !serviceKey) {
      return new Response(JSON.stringify({ error: "Missing Supabase admin secrets" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const admin = createClient(supabaseUrl, serviceKey);

    let totalProcessed = 0;
    let totalSent = 0;
    let totalCancelled = 0;
    let totalFailed = 0;
    let totalDeferred = 0;
    let lastFailure: Record<string, unknown> | null = null;

    while (true) {
      const nowIso = new Date().toISOString();
      const { data: jobs, error } = await admin
        .from("challenge_notification_jobs")
        .select("id, user_id, challenge_id, day_number, kind, payload")
        .eq("status", "pending")
        .lte("scheduled_for", nowIso)
        .order("scheduled_for", { ascending: true })
        .limit(BATCH_SIZE);
      if (error) throw error;
      if (!jobs?.length) break;

      const sorted = [...jobs].sort(
        (a, b) => kindPriority(String(b.kind)) - kindPriority(String(a.kind)),
      );

      for (const job of sorted) {
        totalProcessed++;
        const kind = String(job.kind ?? "");
        const challengeId = String(job.challenge_id ?? "");
        const dayNumber = Number(job.day_number ?? 0);
        const userId = String(job.user_id ?? "");

        const { data: progressRow } = await admin
          .from("challenge_progress")
          .select("status")
          .eq("challenge_id", challengeId)
          .eq("day_number", dayNumber)
          .maybeSingle();

        if (progressRow?.status === "done" && kind !== "completion") {
          await markJob(admin, job.id, "cancelled");
          totalCancelled++;
          continue;
        }

        const todayStart = new Date();
        todayStart.setUTCHours(0, 0, 0, 0);
        const { count: sentToday } = await admin
          .from("challenge_notification_jobs")
          .select("id", { count: "exact", head: true })
          .eq("user_id", userId)
          .eq("challenge_id", challengeId)
          .eq("status", "sent")
          .gte("sent_at", todayStart.toISOString());

        if ((sentToday ?? 0) >= DAILY_CAP && kind !== "completion") {
          await deferJob(admin, job.id);
          totalDeferred++;
          continue;
        }

        const payload = (job.payload ?? {}) as Record<string, unknown>;
        const title = String(payload.title ?? `Day ${dayNumber} is ready!`);
        const body = String(payload.body ?? "Open app to continue your challenge.");
        const deepLink = String(payload.deepLink ?? `/challenge/day${dayNumber}`);

        const sendResult = await invokeSendChallengePush(supabaseUrl, serviceKey, {
          userId,
          title,
          body,
          data: {
            deepLink,
            day: String(dayNumber),
            kind,
            challengeId,
          },
        });

        if (!sendResult.ok) {
          console.error("send-challenge-push failed", sendResult.error, sendResult.body);
          await markJob(admin, job.id, "failed");
          totalFailed++;
          lastFailure = {
            jobId: job.id,
            userId,
            error: sendResult.error,
            body: sendResult.body,
          };
          continue;
        }

        const sent = sendResult.sent;
        const sendErrors = sendResult.errors;
        if (sent < 1) {
          console.error("send-challenge-push sent=0", sendResult);
          await markJob(admin, job.id, "failed");
          totalFailed++;
          lastFailure = {
            jobId: job.id,
            userId,
            sendResult,
            errors: sendErrors,
          };
          continue;
        }

        await markJob(admin, job.id, "sent");
        await recordNotifiedAt(admin, challengeId, dayNumber, kind);
        totalSent++;
      }

      break;
    }

    return new Response(
      JSON.stringify({
        processed: totalProcessed,
        sent: totalSent,
        cancelled: totalCancelled,
        failed: totalFailed,
        deferred: totalDeferred,
        lastFailure,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

function kindPriority(kind: string): number {
  return KIND_PRIORITY[kind] ?? 0;
}

async function invokeSendChallengePush(
  supabaseUrl: string,
  serviceKey: string,
  body: Record<string, unknown>,
): Promise<{
  ok: boolean;
  sent: number;
  errors: string[];
  error?: string;
  body?: unknown;
}> {
  const url = `${supabaseUrl}/functions/v1/send-challenge-push`;
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
    },
    body: JSON.stringify(body),
  });

  const text = await response.text();
  let parsed: Record<string, unknown> = {};
  try {
    parsed = text ? JSON.parse(text) : {};
  } catch {
    parsed = { raw: text };
  }

  if (!response.ok) {
    return {
      ok: false,
      sent: 0,
      errors: [],
      error: `HTTP ${response.status}`,
      body: parsed,
    };
  }

  const sent = Number(parsed.sent ?? 0);
  const errors = Array.isArray(parsed.errors)
    ? parsed.errors.map(String)
    : [];
  return { ok: sent >= 1, sent, errors, body: parsed };
}

async function deferJob(
  admin: ReturnType<typeof createClient>,
  jobId: string,
) {
  const deferUntil = new Date(Date.now() + 4 * 60 * 60 * 1000).toISOString();
  await admin.from("challenge_notification_jobs").update({
    scheduled_for: deferUntil,
    updated_at: new Date().toISOString(),
  }).eq("id", jobId);
}

async function markJob(
  admin: ReturnType<typeof createClient>,
  jobId: string,
  status: "sent" | "failed" | "cancelled",
) {
  const patch: Record<string, string> = {
    status,
    updated_at: new Date().toISOString(),
  };
  if (status === "sent") {
    patch.sent_at = new Date().toISOString();
  }
  await admin.from("challenge_notification_jobs").update(patch).eq("id", jobId);
}

async function recordNotifiedAt(
  admin: ReturnType<typeof createClient>,
  challengeId: string,
  dayNumber: number,
  kind: string,
) {
  const now = new Date().toISOString();
  if (kind === "unlock") {
    await admin
      .from("challenge_progress")
      .update({ unlock_notified_at: now })
      .eq("challenge_id", challengeId)
      .eq("day_number", dayNumber);
  } else if (kind === "reminder" || kind === "streak" || kind === "evening") {
    await admin
      .from("challenge_progress")
      .update({ reminder_sent_at: now })
      .eq("challenge_id", challengeId)
      .eq("day_number", dayNumber);
  } else if (kind === "completion") {
    await admin
      .from("challenge_plans")
      .update({ completion_notified_at: now })
      .eq("id", challengeId);
  }
}
