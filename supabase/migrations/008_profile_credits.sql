-- Subscription credit system for AI generations (5 credits per scan).

alter table public.profiles
  add column if not exists subscription_plan text default 'free',
  add column if not exists credits_balance int default 0,
  add column if not exists credits_period_key text,
  add column if not exists credits_allocated int default 0;

comment on column public.profiles.subscription_plan is 'free | annual | pro_weekly';
comment on column public.profiles.credits_balance is 'Remaining AI credits in current billing period';
comment on column public.profiles.credits_period_key is 'Year (annual) or ISO week key (pro_weekly) for renewal';
comment on column public.profiles.credits_allocated is 'Credits granted when period started (200 or 30)';
