-- Engagement-based Beauty Score Showdown leaderboard support.
alter table public.profiles
  add column if not exists showdown_avatar_url text;

create or replace function public.get_showdown_leaderboard(p_limit int default 100)
returns table (
  user_id uuid,
  display_name text,
  showdown_avatar_url text,
  engagement_score bigint,
  beauty_score_avg numeric
)
language sql
security definer
set search_path = public
as $$
  select
    p.id as user_id,
    coalesce(
      nullif(trim(p.display_name), ''),
      nullif(split_part(coalesce(p.email, ''), '@', 1), ''),
      'Member'
    ) as display_name,
    p.showdown_avatar_url,
    (
      coalesce(sc.scan_count, 0) * 2
      + coalesce(cp.done_days, 0) * 5
      + coalesce(sc.recent_scans, 0) * 3
    )::bigint as engagement_score,
    coalesce(bs.avg_score, 7.5)::numeric as beauty_score_avg
  from public.profiles p
  left join (
    select
      user_id,
      count(*)::int as scan_count,
      count(*) filter (where created_at > now() - interval '7 days')::int as recent_scans
    from public.scans
    group by user_id
  ) sc on sc.user_id = p.id
  left join (
    select
      user_id,
      count(*) filter (where status = 'done')::int as done_days
    from public.challenge_progress
    group by user_id
  ) cp on cp.user_id = p.id
  left join (
    select
      user_id,
      avg(nullif(payload->>'yourScore', '')::numeric) as avg_score
    from public.scans
    where feature_type = 'BEAUTY_SCORE_SHOWDOWN'
      and payload ? 'yourScore'
    group by user_id
  ) bs on bs.user_id = p.id
  where coalesce(sc.scan_count, 0) > 0
  order by engagement_score desc, beauty_score_avg desc nulls last
  limit greatest(p_limit, 1);
$$;

revoke all on function public.get_showdown_leaderboard(int) from public;
grant execute on function public.get_showdown_leaderboard(int) to service_role;
