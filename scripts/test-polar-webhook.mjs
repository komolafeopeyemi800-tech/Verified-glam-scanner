/**
 * Signed POST to polar-webhook using Polar's Standard Webhooks signing (same as @polar-sh/sdk).
 * Usage: node scripts/test-polar-webhook.mjs
 */
import crypto from "crypto";
import fs from "fs";
import path from "path";
import { Webhook } from "standardwebhooks";

const root = path.resolve(import.meta.dirname, "..");
const envPath = path.join(root, ".env");
if (fs.existsSync(envPath)) {
  for (const line of fs.readFileSync(envPath, "utf8").split("\n")) {
    const t = line.trim();
    if (!t || t.startsWith("#")) continue;
    const i = t.indexOf("=");
    if (i < 1) continue;
    const k = t.slice(0, i).trim();
    const v = t.slice(i + 1).trim();
    if (!process.env[k]) process.env[k] = v;
  }
}

const secret = process.env.POLAR_WEBHOOK_SECRET?.trim();
const url =
  process.env.POLAR_WEBHOOK_URL?.trim() ||
  "https://qmivgvctmxvpnbouqslj.supabase.co/functions/v1/polar-webhook";

if (!secret) {
  console.error("Missing POLAR_WEBHOOK_SECRET in .env or environment");
  process.exit(1);
}

// Matches @polar-sh/sdk validateEvent: base64(utf8(secret)) passed to standardwebhooks Webhook.
const base64Secret = Buffer.from(secret, "utf-8").toString("base64");
const webhook = new Webhook(base64Secret);

const body = JSON.stringify({
  type: "subscription.active",
  data: {
    id: "test-sub-webhook-probe",
    status: "active",
    product_id: "9e185286-cf2b-41b8-a728-e7154d144722",
    customer: {
      email: "webhook-test@verifiedglam.app",
      external_id: "00000000-0000-4000-8000-000000000001",
    },
  },
});

const msgId = crypto.randomUUID();
const now = new Date();
const signature = webhook.sign(msgId, now, body);

const res = await fetch(url, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "webhook-id": msgId,
    "webhook-timestamp": Math.floor(now.getTime() / 1000).toString(),
    "webhook-signature": signature,
  },
  body,
});

const text = await res.text();
let parsed;
try {
  parsed = JSON.parse(text);
} catch {
  parsed = text;
}

const ok = res.status === 202 || res.status === 200;
const signatureOk =
  ok ||
  (res.status === 400 &&
    parsed &&
    typeof parsed === "object" &&
    parsed.error === "Invalid payload");
const formatOk = secret.startsWith("whsec_") && secret.length >= 20;

console.log(
  JSON.stringify(
    {
      ok,
      status: res.status,
      secretFormatValid: formatOk,
      signatureVerified: signatureOk,
      secretPrefix: secret.slice(0, 12) + "...",
      response: parsed,
      hint: ok
        ? "Webhook fully accepted (202)."
        : signatureOk
          ? "Signature OK — secret matches. Polar real events should return 202."
          : res.status === 403
            ? "Invalid signature — sync POLAR_WEBHOOK_SECRET via set-polar-secrets.ps1"
            : `Unexpected HTTP ${res.status}`,
    },
    null,
    2,
  ),
);

process.exit(ok || signatureOk ? 0 : 1);
