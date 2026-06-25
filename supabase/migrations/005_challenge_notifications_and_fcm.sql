alter table public.challenge_progress
  add column if not exists unlock_notified_at timestamptz,
  add column if not exists reminder_sent_at timestamptz;

alter table public.challenge_plans
  add column if not exists completion_notified_at timestamptz;

create table if not exists public.device_push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  fcm_token text not null unique,
  platform text not null,
  is_active boolean not null default true,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.challenge_notification_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  challenge_id text not null references public.challenge_plans(id) on delete cascade,
  day_number int not null,
  kind text not null check (kind in ('unlock', 'reminder', 'completion')),
  scheduled_for timestamptz not null,
  sent_at timestamptz,
  status text not null default 'pending' check (status in ('pending', 'sent', 'failed', 'cancelled')),
  payload jsonb not null default '{}'::jsonb,
  dedupe_key text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists idx_challenge_notification_jobs_dedupe
  on public.challenge_notification_jobs(dedupe_key)
  where dedupe_key is not null;

alter table public.device_push_tokens enable row level security;
alter table public.challenge_notification_jobs enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='device_push_tokens' and policyname='device_push_tokens_select_own'
  ) then
    create policy "device_push_tokens_select_own" on public.device_push_tokens
      for select using (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='device_push_tokens' and policyname='device_push_tokens_insert_own'
  ) then
    create policy "device_push_tokens_insert_own" on public.device_push_tokens
      for insert with check (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='device_push_tokens' and policyname='device_push_tokens_update_own'
  ) then
    create policy "device_push_tokens_update_own" on public.device_push_tokens
      for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;

  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='challenge_notification_jobs' and policyname='challenge_notification_jobs_select_own'
  ) then
    create policy "challenge_notification_jobs_select_own" on public.challenge_notification_jobs
      for select using (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='challenge_notification_jobs' and policyname='challenge_notification_jobs_insert_own'
  ) then
    create policy "challenge_notification_jobs_insert_own" on public.challenge_notification_jobs
      for insert with check (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='challenge_notification_jobs' and policyname='challenge_notification_jobs_update_own'
  ) then
    create policy "challenge_notification_jobs_update_own" on public.challenge_notification_jobs
      for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;
end
$$;
