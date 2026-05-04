# CI/CD

This repository uses trunk-based infrastructure deployment.

- Pull requests target `main` and run Terraform fmt, validate, and plan.
- Plans are posted back to the pull request per stack and environment.
- Pushes to `main` apply the test environment.
- Tags matching `v*` apply the production environment after the `prod` GitHub Environment is approved.
- Manual production re-apply checks out a requested tag or commit SHA through the same production approval gate.

Required GitHub Environments:

- `test`
- `prod`

Environment variables/secrets expected by the workflow:

- `GCP_WIF_PROVIDER`
- `GCP_WIF_SERVICE_ACCOUNT`
- `TF_STATE_BUCKET_TEST`
- `TF_STATE_BUCKET_PROD`
- `TF_VAR_GOOGLE_GENAI_API_KEY`
- `TF_VAR_STRIPE_SECRET_KEY`
- `TF_VAR_STRIPE_WEBHOOK_SECRET`

For pull-request plans, environment-specific variants are also supported:

- `GCP_WIF_PROVIDER_TEST`
- `GCP_WIF_SERVICE_ACCOUNT_TEST`
- `GCP_WIF_PROVIDER_PROD`
- `GCP_WIF_SERVICE_ACCOUNT_PROD`
- `TF_VAR_GOOGLE_GENAI_API_KEY_TEST`
- `TF_VAR_GOOGLE_GENAI_API_KEY_PROD`
- `TF_VAR_STRIPE_SECRET_KEY_TEST`
- `TF_VAR_STRIPE_SECRET_KEY_PROD`
- `TF_VAR_STRIPE_WEBHOOK_SECRET_TEST`
- `TF_VAR_STRIPE_WEBHOOK_SECRET_PROD`
