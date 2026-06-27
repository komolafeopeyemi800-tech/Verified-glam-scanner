import { Polar } from "npm:@polar-sh/sdk@0.32.16";

export function polarServer(): "sandbox" | "production" {
  return Deno.env.get("POLAR_ENV") === "production" ? "production" : "sandbox";
}

export function polarAccessToken(): string | null {
  const token = Deno.env.get("POLAR_ACCESS_TOKEN")?.trim();
  return token || null;
}

/** UUID from Polar → Settings → Organization → "Unique identifier for your organization". */
export function polarOrganizationId(): string | null {
  const id = Deno.env.get("POLAR_ORGANIZATION_ID")?.trim();
  return id || null;
}

/** Slug used in polar.sh/{slug}/portal and checkout branding. */
export function polarOrganizationSlug(): string | null {
  const slug = Deno.env.get("POLAR_ORGANIZATION_SLUG")?.trim();
  return slug || null;
}

export function createPolarClient(): Polar | null {
  const accessToken = polarAccessToken();
  if (!accessToken) return null;
  return new Polar({ accessToken, server: polarServer() });
}

export function defaultPortalUrl(): string | null {
  const slug = polarOrganizationSlug();
  if (!slug) return null;
  const host = polarServer() === "production" ? "https://polar.sh" : "https://sandbox.polar.sh";
  return `${host}/${slug}/portal`;
}

/** Reject webhook payloads from another Polar org when POLAR_ORGANIZATION_ID is set. */
export function eventOrganizationId(data: Record<string, unknown>): string | null {
  const direct = data.organization_id ?? data.organizationId;
  if (typeof direct === "string" && direct.length > 0) return direct;

  const org = data.organization as Record<string, unknown> | undefined;
  if (org && typeof org.id === "string") return org.id;

  return null;
}

export function assertEventOrganization(data: Record<string, unknown>): string | null {
  const expected = polarOrganizationId();
  if (!expected) return null;

  const actual = eventOrganizationId(data);
  if (actual && actual !== expected) {
    return `Webhook organization_id mismatch (expected ${expected}, got ${actual})`;
  }
  return null;
}

const DEFAULT_APP_ORIGIN = "https://scanner.verifiedglam.com";
const DEFAULT_SUCCESS_PATH = "/app/face-beauty-analysis?checkout=success";
const DEFAULT_CANCEL_PATH = "/pricing?checkout=cancelled";

/** Where Polar sends the customer after successful payment. */
export function polarSuccessUrl(): string {
  const configured = Deno.env.get("POLAR_SUCCESS_URL")?.trim();
  if (configured) return configured;

  const origin = Deno.env.get("POLAR_APP_BASE_URL")?.trim()?.replace(/\/$/, "") ??
    DEFAULT_APP_ORIGIN;
  return `${origin}${DEFAULT_SUCCESS_PATH}`;
}

/** Where Polar sends the customer when checkout is cancelled or abandoned. */
export function polarCancelUrl(): string {
  const configured = Deno.env.get("POLAR_CANCEL_URL")?.trim();
  if (configured) return configured;

  const origin = Deno.env.get("POLAR_APP_BASE_URL")?.trim()?.replace(/\/$/, "") ??
    DEFAULT_APP_ORIGIN;
  return `${origin}${DEFAULT_CANCEL_PATH}`;
}

export function polarCheckoutLinkForPlan(planId: string): string | null {
  if (planId === "annual") {
    return Deno.env.get("POLAR_CHECKOUT_LINK_ANNUAL")?.trim() || null;
  }
  if (planId === "pro_weekly") {
    return Deno.env.get("POLAR_CHECKOUT_LINK_PRO_WEEKLY")?.trim() || null;
  }
  return null;
}

/** Static Polar checkout link with customer binding (see Polar Checkout Links query params). */
export function buildCheckoutLinkUrl(
  baseLink: string,
  userId: string,
  email?: string | null,
): string {
  const url = new URL(baseLink);
  url.searchParams.set("customerExternalId", userId);
  if (email) url.searchParams.set("customerEmail", email);
  return url.toString();
}
