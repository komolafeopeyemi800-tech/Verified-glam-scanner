-- Verified Glam — Supabase initial schema

-- Profiles (extends auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  display_name text,
  age int,
  gender text,
  beauty_goals jsonb default '[]'::jsonb,
  skin_concerns jsonb default '[]'::jsonb,
  product_preferences jsonb default '[]'::jsonb,
  skin_type text,
  ethnicity text,
  aesthetic text,
  onboarding_complete boolean default false,
  referral_code text unique,
  referral_download_count int default 0,
  bonus_scans int default 0,
  referral_bonus_redeemed boolean default false,
  is_pro boolean default false,
  daily_scan_count int default 0,
  daily_scan_date date,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Scan history
create table if not exists public.scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  feature_type text not null,
  feature_title text not null,
  photo_storage_path text,
  photo_public_url text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz default now()
);

create index if not exists scans_user_created_idx on public.scans (user_id, created_at desc);

-- Referral events (optional v1)
create table if not exists public.referral_events (
  id uuid primary key default gen_random_uuid(),
  referrer_id uuid references public.profiles (id) on delete set null,
  referred_user_id uuid references public.profiles (id) on delete set null,
  created_at timestamptz default now()
);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- RLS
alter table public.profiles enable row level security;
alter table public.scans enable row level security;
alter table public.referral_events enable row level security;

create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

create policy "scans_select_own" on public.scans
  for select using (auth.uid() = user_id);

create policy "scans_insert_own" on public.scans
  for insert with check (auth.uid() = user_id);

create policy "scans_delete_own" on public.scans
  for delete using (auth.uid() = user_id);

create policy "referral_events_select_own" on public.referral_events
  for select using (auth.uid() = referrer_id or auth.uid() = referred_user_id);

-- Storage bucket (private scan photos)
insert into storage.buckets (id, name, public)
values ('scan-photos', 'scan-photos', false)
on conflict (id) do nothing;

create policy "scan_photos_select_own"
on storage.objects for select
using (
  bucket_id = 'scan-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "scan_photos_insert_own"
on storage.objects for insert
with check (
  bucket_id = 'scan-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "scan_photos_update_own"
on storage.objects for update
using (
  bucket_id = 'scan-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "scan_photos_delete_own"
on storage.objects for delete
using (
  bucket_id = 'scan-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
);
