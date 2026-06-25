-- Public bucket for cached Beauty Score Showdown rival / member avatars.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'showdown-avatars',
  'showdown-avatars',
  true,
  524288,
  array['image/png', 'image/jpeg', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Public read showdown avatars" on storage.objects;
create policy "Public read showdown avatars"
on storage.objects for select
using (bucket_id = 'showdown-avatars');
