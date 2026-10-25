-- Supabase-hosted scheduling. Before applying this migration, create three
-- Vault secrets from the Supabase SQL editor (see COURSE_CHECKOUT.md):
-- course_checkout_project_url, course_checkout_service_role_key, and
-- course_checkout_reconciliation_secret.
create extension if not exists pg_cron;
create extension if not exists pg_net;

select cron.unschedule(jobid)
from cron.job
where jobname = 'reconcile-course-payments';

select cron.schedule(
  'reconcile-course-payments',
  '*/5 * * * *',
  $job$
  select net.http_post(
    url := (select decrypted_secret from vault.decrypted_secrets where name = 'course_checkout_project_url')
      || '/functions/v1/reconcile-course-payments',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'apikey', (select decrypted_secret from vault.decrypted_secrets where name = 'course_checkout_service_role_key'),
      'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'course_checkout_service_role_key'),
      'x-reconciliation-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'course_checkout_reconciliation_secret')
    ),
    body := '{}'::jsonb
  );
  $job$
);
