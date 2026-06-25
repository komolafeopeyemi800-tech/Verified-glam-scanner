create table if not exists public.challenge_plans (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  source_scan_id uuid references public.scans(id) on delete set null,
  issue_tag text not null,
  severity text not null check (severity in ('low', 'medium', 'high')),
  duration_days int not null check (duration_days in (3, 5, 7)),
  title text not null,
  intro_message text not null,
  disclaimer text not null,
  completed_days int not null default 0,
  last_completed_at timestamptz,
  next_unlock_at timestamptz,
  is_completed boolean not null default false,
  streak_count int not null default 0,
  notification_pref_time text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.challenge_days (
  id uuid primary key default gen_random_uuid(),
  challenge_id text not null references public.challenge_plans(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  day_number int not null check (day_number > 0),
  title text not null,
  main_task text not null,
  support_task text not null,
  why_line text not null,
  est_minutes int not null default 10,
  created_at timestamptz not null default now(),
  unique (challenge_id, day_number)
);

create table if not exists public.challenge_progress (
  id uuid primary key default gen_random_uuid(),
  challenge_id text not null references public.challenge_plans(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  day_number int not null check (day_number > 0),
  status text not null check (status in ('locked', 'unlocked', 'done')),
  unlocked_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (challenge_id, day_number)
);

alter table public.challenge_plans enable row level security;
alter table public.challenge_days enable row level security;
alter table public.challenge_progress enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'challenge_plans' and policyname = 'challenge_plans_select_own'
  ) then
    create policy "challenge_plans_select_own" on public.challenge_plans for select using (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'challenge_plans' and policyname = 'challenge_plans_insert_own'
  ) then
    create policy "challenge_plans_insert_own" on public.challenge_plans for insert with check (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'challenge_plans' and policyname = 'challenge_plans_update_own'
  ) then
    create policy "challenge_plans_update_own" on public.challenge_plans for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;

  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'challenge_days' and policyname = 'challenge_days_select_own'
  ) then
    create policy "challenge_days_select_own" on public.challenge_days for select using (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'challenge_days' and policyname = 'challenge_days_insert_own'
  ) then
    create policy "challenge_days_insert_own" on public.challenge_days for insert with check (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'challenge_days' and policyname = 'challenge_days_update_own'
  ) then
    create policy "challenge_days_update_own" on public.challenge_days for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;

  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'challenge_progress' and policyname = 'challenge_progress_select_own'
  ) then
    create policy "challenge_progress_select_own" on public.challenge_progress for select using (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'challenge_progress' and policyname = 'challenge_progress_insert_own'
  ) then
    create policy "challenge_progress_insert_own" on public.challenge_progress for insert with check (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'challenge_progress' and policyname = 'challenge_progress_update_own'
  ) then
    create policy "challenge_progress_update_own" on public.challenge_progress for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;
end
$$;
