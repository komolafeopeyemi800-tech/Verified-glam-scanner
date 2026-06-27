import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

export const CREDITS_PER_GENERATION = 5;
export const YEARLY_CREDITS_ALLOCATION = 200;
export const PRO_WEEKLY_CREDITS_ALLOCATION = 30;

export const POLAR_PRODUCT_ID_ANNUAL_DEFAULT = "9e185286-cf2b-41b8-a728-e7154d144722";
export const POLAR_PRODUCT_ID_PRO_WEEKLY_DEFAULT = "8c9fddc9-1001-4143-8a27-31ce929ae5e6";

export type SubscriptionPlan = "free" | "annual" | "pro_weekly";

export function polarProductIds(): { annual: string; proWeekly: string } {
  return {
    annual: Deno.env.get("POLAR_PRODUCT_ID_ANNUAL") ?? POLAR_PRODUCT_ID_ANNUAL_DEFAULT,
    proWeekly: Deno.env.get("POLAR_PRODUCT_ID_PRO_WEEKLY") ?? POLAR_PRODUCT_ID_PRO_WEEKLY_DEFAULT,
  };
}

export function planForPolarProductId(productId: string): SubscriptionPlan | null {
  const ids = polarProductIds();
  if (productId === ids.annual) return "annual";
  if (productId === ids.proWeekly) return "pro_weekly";
  return null;
}

export function currentPeriodKey(plan: SubscriptionPlan): string {
  const now = new Date();
  if (plan === "pro_weekly") {
    const d = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    const weekNo = Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7);
    return `${d.getUTCFullYear()}-W${String(weekNo).padStart(2, "0")}`;
  }
  if (plan === "annual") {
    return String(now.getUTCFullYear());
  }
  return "";
}

export function allocationForPlan(plan: SubscriptionPlan): number {
  if (plan === "pro_weekly") return PRO_WEEKLY_CREDITS_ALLOCATION;
  if (plan === "annual") return YEARLY_CREDITS_ALLOCATION;
  return 0;
}

export function createAdminClient() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  return createClient(supabaseUrl, serviceRole);
}

export async function grantSubscriptionCredits(
  admin: ReturnType<typeof createAdminClient>,
  userId: string,
  plan: SubscriptionPlan,
  opts: {
    polarCustomerId?: string | null;
    polarSubscriptionId?: string | null;
    subscriptionStatus?: string;
    periodEnd?: string | null;
    forceRefresh?: boolean;
  } = {},
): Promise<void> {
  const allocated = allocationForPlan(plan);
  const periodKey = currentPeriodKey(plan);
  const now = new Date().toISOString();

  const { data: existing } = await admin
    .from("profiles")
    .select("credits_period_key, credits_allocated, credits_balance")
    .eq("id", userId)
    .maybeSingle();

  const samePeriod = existing?.credits_period_key === periodKey &&
    (existing?.credits_allocated ?? 0) === allocated;
  const balance = opts.forceRefresh || !samePeriod
    ? allocated
    : (existing?.credits_balance ?? allocated);

  const update: Record<string, unknown> = {
    is_pro: true,
    subscription_plan: plan,
    subscription_status: opts.subscriptionStatus ?? "active",
    credits_balance: balance,
    credits_allocated: allocated,
    credits_period_key: periodKey,
    updated_at: now,
  };

  if (opts.polarCustomerId) update.polar_customer_id = opts.polarCustomerId;
  if (opts.polarSubscriptionId) update.polar_subscription_id = opts.polarSubscriptionId;
  if (opts.periodEnd) update.subscription_current_period_end = opts.periodEnd;

  await admin.from("profiles").update(update).eq("id", userId);
}

export async function revokeSubscription(
  admin: ReturnType<typeof createAdminClient>,
  userId: string,
  opts: {
    subscriptionStatus: string;
    periodEnd?: string | null;
    retainAccessUntilPeriodEnd?: boolean;
  },
): Promise<void> {
  const now = new Date();
  const periodEnd = opts.periodEnd ? new Date(opts.periodEnd) : null;
  const retain = opts.retainAccessUntilPeriodEnd && periodEnd && periodEnd > now;

  const update: Record<string, unknown> = {
    subscription_status: opts.subscriptionStatus,
    subscription_current_period_end: opts.periodEnd ?? null,
    updated_at: now.toISOString(),
  };

  if (retain) {
    update.is_pro = true;
  } else {
    update.is_pro = false;
    update.subscription_plan = "free";
    update.credits_balance = 0;
    update.credits_allocated = 0;
    update.credits_period_key = null;
    update.polar_subscription_id = null;
  }

  await admin.from("profiles").update(update).eq("id", userId);
}

export function extractUserIdFromCustomer(customer: Record<string, unknown> | null | undefined): string | null {
  if (!customer) return null;
  const externalId = customer.external_id ?? customer.externalId;
  if (typeof externalId === "string" && externalId.length > 0) return externalId;
  return null;
}

export function extractProductId(subscription: Record<string, unknown>): string | null {
  const product = subscription.product as Record<string, unknown> | undefined;
  if (product?.id && typeof product.id === "string") return product.id;
  const productId = subscription.product_id ?? subscription.productId;
  if (typeof productId === "string") return productId;
  return null;
}
