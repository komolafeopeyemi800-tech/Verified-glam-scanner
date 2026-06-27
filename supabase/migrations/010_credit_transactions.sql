-- Credit transaction ledger for subscription grants and analysis usage.

create table if not exists public.credit_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  amount int not null,
  kind text not null check (kind in (
    'subscription_grant',
    'period_refresh',
    'analysis',
    'subscription_revoke'
  )),
  description text not null,
  feature_type text,
  balance_after int,
  created_at timestamptz not null default now()
);

create index if not exists credit_transactions_user_created_idx
  on public.credit_transactions (user_id, created_at desc);

alter table public.credit_transactions enable row level security;

drop policy if exists "Users read own credit transactions" on public.credit_transactions;
create policy "Users read own credit transactions"
  on public.credit_transactions
  for select
  using (auth.uid() = user_id);
