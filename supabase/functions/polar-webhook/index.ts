import {
  validateEvent,
  WebhookVerificationError,
} from "https://esm.sh/@polar-sh/sdk/webhooks@0.32.16";
import {
  createAdminClient,
  extractProductId,
  extractUserIdFromCustomer,
  grantSubscriptionCredits,
  planForPolarProductId,
  revokeSubscription,
  type SubscriptionPlan,
} from "../_shared/credits.ts";

const FUNCTION_VERSION = "1";

function json(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify({ ...body, version: FUNCTION_VERSION }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

async function isDuplicateEvent(admin: ReturnType<typeof createAdminClient>, eventId: string): Promise<boolean> {
  const { data } = await admin
    .from("polar_webhook_events")
    .select("id")
    .eq("id", eventId)
    .maybeSingle();
  return data != null;
}

async function markEventProcessed(
  admin: ReturnType<typeof createAdminClient>,
  eventId: string,
  eventType: string,
): Promise<void> {
  await admin.from("polar_webhook_events").insert({ id: eventId, event_type: eventType });
}

function periodEndIso(data: Record<string, unknown>): string | null {
  const raw = data.current_period_end ?? data.currentPeriodEnd;
  return typeof raw === "string" ? raw : null;
}

function customerFromPayload(data: Record<string, unknown>): Record<string, unknown> | null {
  const customer = data.customer as Record<string, unknown> | undefined;
  return customer ?? null;
}

async function handleSubscriptionActive(
  admin: ReturnType<typeof createAdminClient>,
  data: Record<string, unknown>,
  forceRefresh = false,
): Promise<void> {
  const userId = extractUserIdFromCustomer(customerFromPayload(data));
  if (!userId) {
    console.warn("Polar webhook: missing external customer id", data.id);
    return;
  }

  const productId = extractProductId(data);
  if (!productId) {
    console.warn("Polar webhook: missing product id", data.id);
    return;
  }

  const plan = planForPolarProductId(productId);
  if (!plan) {
    console.warn("Polar webhook: unknown product", productId);
    return;
  }

  const customer = customerFromPayload(data);
  await grantSubscriptionCredits(admin, userId, plan, {
    polarCustomerId: typeof customer?.id === "string" ? customer.id : null,
    polarSubscriptionId: typeof data.id === "string" ? data.id : null,
    subscriptionStatus: typeof data.status === "string" ? data.status : "active",
    periodEnd: periodEndIso(data),
    forceRefresh,
  });
}

async function handleSubscriptionRevoked(
  admin: ReturnType<typeof createAdminClient>,
  data: Record<string, unknown>,
  status: "canceled" | "revoked" | "past_due",
): Promise<void> {
  const userId = extractUserIdFromCustomer(customerFromPayload(data));
  if (!userId) return;

  const retain = status === "canceled";
  await revokeSubscription(admin, userId, {
    subscriptionStatus: status,
    periodEnd: periodEndIso(data),
    retainAccessUntilPeriodEnd: retain,
  });
}

async function handleOrderRenewal(
  admin: ReturnType<typeof createAdminClient>,
  data: Record<string, unknown>,
): Promise<void> {
  const billingReason = data.billing_reason ?? data.billingReason;
  if (billingReason !== "subscription_cycle") return;

  const subscription = data.subscription as Record<string, unknown> | undefined;
  if (subscription) {
    await handleSubscriptionActive(admin, subscription, true);
    return;
  }

  const userId = extractUserIdFromCustomer(customerFromPayload(data));
  if (!userId) return;

  const product = data.product as Record<string, unknown> | undefined;
  const productId = typeof product?.id === "string" ? product.id : null;
  if (!productId) return;

  const plan = planForPolarProductId(productId);
  if (!plan) return;

  await grantSubscriptionCredits(admin, userId, plan, {
    subscriptionStatus: "active",
    forceRefresh: true,
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json(405, { error: "Method not allowed" });
  }

  const webhookSecret = Deno.env.get("POLAR_WEBHOOK_SECRET")?.trim();
  if (!webhookSecret) {
    console.error("POLAR_WEBHOOK_SECRET not configured");
    return json(503, { error: "Webhook not configured" });
  }

  const rawBody = await req.text();
  let event: { type: string; data: Record<string, unknown> };

  try {
    event = validateEvent(rawBody, req.headers, webhookSecret) as {
      type: string;
      data: Record<string, unknown>;
    };
  } catch (e) {
    if (e instanceof WebhookVerificationError) {
      return json(403, { error: "Invalid signature" });
    }
    console.error(e);
    return json(400, { error: "Invalid payload" });
  }

  const eventId = req.headers.get("webhook-id") ?? crypto.randomUUID();
  const admin = createAdminClient();

  if (await isDuplicateEvent(admin, eventId)) {
    return json(202, { ok: true, duplicate: true });
  }

  try {
    const type = event.type;
    const data = event.data ?? {};

    switch (type) {
      case "subscription.active":
        await handleSubscriptionActive(admin, data);
        break;
      case "subscription.updated": {
        const status = typeof data.status === "string" ? data.status : "";
        if (status === "active") {
          await handleSubscriptionActive(admin, data);
        } else if (status === "past_due") {
          await handleSubscriptionRevoked(admin, data, "past_due");
        } else if (status === "canceled") {
          await handleSubscriptionRevoked(admin, data, "canceled");
        }
        break;
      }
      case "subscription.canceled":
        await handleSubscriptionRevoked(admin, data, "canceled");
        break;
      case "subscription.revoked":
        await handleSubscriptionRevoked(admin, data, "revoked");
        break;
      case "order.created":
        await handleOrderRenewal(admin, data);
        break;
      default:
        break;
    }

    await markEventProcessed(admin, eventId, type);
    return json(202, { ok: true });
  } catch (e) {
    console.error("Polar webhook handler error", e);
    return json(500, { error: e instanceof Error ? e.message : "Handler failed" });
  }
});
