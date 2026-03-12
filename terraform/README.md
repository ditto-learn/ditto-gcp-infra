# Terraform Layout (local / test / prod)

This repository uses:

- `local`: Supabase CLI and local services (`dev.sh`) only.
- `test`: Terraform-managed Supabase + GCP.
- `prod`: Terraform-managed Supabase + GCP.

## Structure

- `main.tf`, `variables.tf`, `providers.tf`, `outputs.tf`: single root stack.
- `modules/supabase`: Supabase project + API key retrieval.
- `modules/gcp_runtime`: Cloud Run runtimes, networking, secrets, bucket, APIs.
- `modules/cloud_run_service`: Reusable Cloud Run service definition.
- `environments/test.tfvars`, `environments/prod.tfvars`: environment-specific values.
- `environments/*.secrets.auto.tfvars` (local, untracked): sensitive values.

## London Policy

- GCP region is hard-pinned to `europe-west2`.
- Supabase region is hard-pinned to `eu-west-2`.

Any deviation fails Terraform validation.

## Secret Inputs

`supabase_access_token`, `supabase_database_password`, `google_genai_api_key`,
and `supabase_jwt_secret` are required. Terraform does not auto-generate
fallback secrets.

Cloud Run invocation is hard-cut to one caller principal per environment:
the managed Next.js service account (`web-backend-test` / `web-backend-prod`).
`roles/run.invoker` is managed authoritatively per service to prevent IAM drift.

Optional: set `cloud_run_custom_audiences` when you want stable custom `aud`
claims for Cloud Run ID token verification.

## Vercel OIDC WIF

Each environment must set `vercel_oidc` in `environments/<env>.tfvars`:

- `workload_identity_pool_id`
- `workload_identity_pool_provider_id`
- `issuer_mode` (`team` or `global`)
- `team_slug` (required when `issuer_mode = "team"`)
- `allowed_audiences`
- `allowed_subjects`

Typical team-mode values:

- issuer: `https://oidc.vercel.com/<team_slug>`
- audience: `https://vercel.com/<team_slug>`

Terraform creates:

- Workload Identity Pool + OIDC Provider
- Subject-scoped `roles/iam.workloadIdentityUser` binding on the managed
  Next.js service account
- Self `roles/iam.serviceAccountTokenCreator` on the same service account
  (required for runtime `generateIdToken`)

Use outputs to wire Vercel runtime env vars:

- `gcp_project_number` -> `GCP_PROJECT_NUMBER`
- `vercel_wif_pool_id` -> `GCP_WORKLOAD_IDENTITY_POOL_ID`
- `vercel_wif_provider_id` -> `GCP_WORKLOAD_IDENTITY_POOL_PROVIDER_ID`
- `nextjs_invoker_service_account_email` -> `GCP_SERVICE_ACCOUNT_EMAIL`

## Backend

Each environment uses GCS backend state with different prefixes:

```bash
terraform -chdir=terraform init \
  -backend-config="bucket=<test-state-bucket>" \
  -backend-config="prefix=terraform/test"
terraform -chdir=terraform plan -var-file=environments/test.tfvars
```

For production, use `prefix=terraform/prod` and `-var-file=environments/prod.tfvars`.

Use `scripts/infra/bootstrap-tf-backend.sh` to create backend buckets.

## First Atlas Bootstrap

For a fresh Supabase remote database, run one-time baseline bootstrap before
enabling strict CI applies:

```bash
./scripts/db/bootstrap-remote-baseline.sh test
./scripts/db/bootstrap-remote-baseline.sh prod
```
