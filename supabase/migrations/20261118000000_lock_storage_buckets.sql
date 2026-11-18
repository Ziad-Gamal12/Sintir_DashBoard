-- Lock Supabase Storage for the Sintir app.
--
-- The app signs in with Firebase, so every app request reaches Supabase as the
-- anon role. Any storage policy that lets anon upload, change, delete or list
-- objects is therefore open to the whole internet. After this migration:
--   * uploads go through the create-upload-url Edge Function (signed upload
--     URLs for a server-chosen path),
--   * paid course files live in the private CourseFiles bucket and are opened
--     through get-course-file-url (one-hour signed URLs, enrollment checked),
--   * Courses / Users / Support stay public for reading single files by URL
--     (posters, avatars, support images), but cannot be listed or written.

-- 1) Private bucket for course files (PDF / Office / text).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'CourseFiles',
  'CourseFiles',
  false,
  52428800,
  array[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  ]
)
on conflict (id) do update set
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- 2) Public image buckets: images only, size-capped.
update storage.buckets
set file_size_limit = 10485760,
    allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/heic']
where id in ('Courses', 'Users', 'Support');

-- 3) Remove client policies on these buckets (and bucket-agnostic ones).
--    Signed upload URLs and the service role do not need any policy, and
--    public buckets serve files by URL without one.
do $$
declare
  p record;
begin
  for p in
    select policyname
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and (
        coalesce(qual, '') || ' ' || coalesce(with_check, '')
          ~ '(Courses|Users|Support|CourseFiles)'
        or (coalesce(qual, '') || ' ' || coalesce(with_check, '')) !~ 'bucket_id'
      )
  loop
    execute format('drop policy if exists %I on storage.objects', p.policyname);
  end loop;
end
$$;
