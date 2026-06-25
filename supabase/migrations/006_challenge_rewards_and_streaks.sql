alter table public.challenge_plans
  add column if not exists current_streak int not null default 0,
  add column if not exists best_streak int not null default 0,
  add column if not exists last_done_date date;

create table if not exists public.challenge_badges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  badge_code text not null,
  badge_title text not null,
  challenge_id text references public.challenge_plans(id) on delete set null,
  earned_at timestamptz not null default now(),
  unique (user_id, badge_code)
);

create table if not exists public.challenge_reward_cards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  challenge_id text not null references public.challenge_plans(id) on delete cascade,
  challenge_title text not null,
  issue_tag text not null,
  completed_on timestamptz not null default now(),
  message text not null,
  created_at timestamptz not null default now()
);

alter table public.challenge_badges enable row level security;
alter table public.challenge_reward_cards enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='challenge_badges' and policyname='challenge_badges_select_own'
  ) then
    create policy "challenge_badges_select_own" on public.challenge_badges
      for select using (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='challenge_badges' and policyname='challenge_badges_insert_own'
  ) then
    create policy "challenge_badges_insert_own" on public.challenge_badges
      for insert with check (auth.uid() = user_id);
  end if;

  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='challenge_reward_cards' and policyname='challenge_reward_cards_select_own'
  ) then
    create policy "challenge_reward_cards_select_own" on public.challenge_reward_cards
      for select using (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='challenge_reward_cards' and policyname='challenge_reward_cards_insert_own'
  ) then
    create policy "challenge_reward_cards_insert_own" on public.challenge_reward_cards
      for insert with check (auth.uid() = user_id);
  end if;
end
$$;
