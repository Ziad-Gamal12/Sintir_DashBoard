-- Before applying, add these Vault secrets from the Supabase SQL editor:
-- teacher_withdrawal_project_url, teacher_withdrawal_service_role_key, and
-- teacher_withdrawal_reconciliation_secret.
create extension if not exists pg_cron;
create extension if not exists pg_net;

select cron.unschedule(jobid)
from cron.job
where jobname = 'reconcile-teacher-withdrawals';

select cron.schedule(
  'reconcile-teacher-withdrawals',
  '*/5 * * * *',
  $job$
  select net.http_post(
    url := (select decrypted_secret from vault.decrypted_secrets where name = 'teacher_withdrawal_project_url')
      || '/functions/v1/teacher-withdrawal',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'apikey', (select decrypted_secret from vault.decrypted_secrets where name = 'teacher_withdrawal_service_role_key'),
      'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'teacher_withdrawal_service_role_key'),
      'x-withdrawal-reconciliation-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'teacher_withdrawal_reconciliation_secret')
    ),
    body := '{}'::jsonb
  );
  $job$
);
