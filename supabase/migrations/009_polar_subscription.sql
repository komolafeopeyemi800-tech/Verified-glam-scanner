-- Polar.sh subscription sync (updated by polar-webhook via service role).

alter table public.profiles
  add column if not exists polar_customer_id text,
  add column if not exists polar_subscription_id text,
  add column if not exists subscription_status text default 'free',
  add column if not exists subscription_current_period_end timestamptz;

comment on column public.profiles.polar_customer_id is 'Polar customer ID from checkout/webhook';
comment on column public.profiles.polar_subscription_id is 'Active Polar subscription ID';
comment on column public.profiles.subscription_status is 'free | active | canceled | past_due | revoked';
comment on column public.profiles.subscription_current_period_end is 'Current billing period end from Polar';

create table if not exists public.polar_webhook_events (
  id text primary key,
  event_type text not null,
  processed_at timestamptz not null default now()
);

comment on table public.polar_webhook_events is 'Idempotency log for Polar Standard Webhooks (webhook-id header)';

alter table public.polar_webhook_events enable row level security;
