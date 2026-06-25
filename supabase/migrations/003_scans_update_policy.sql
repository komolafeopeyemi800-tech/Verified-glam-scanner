-- Allow users to update only their own scans rows.
do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'scans'
      and policyname = 'scans_update_own'
  ) then
    create policy "scans_update_own" on public.scans
      for update
      using (auth.uid() = user_id)
      with check (auth.uid() = user_id);
  end if;
end
$$;
