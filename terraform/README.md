# Terraform Components

This directory is the only supported Terraform entrypoint for GCP infrastructure.

## Component model

- platform: APIs, VPC/NAT, Artifact Registry, service accounts, IAM, secrets, audit configs
- database: private service networking + Cloud SQL instance/database/users
- runtime: Cloud Run services, runtime monitoring, and the speech-assets
  Cloud CDN stack. The API itself is still reached directly through Cloud Run
  or its custom domain; do not assume Firebase allowlist exists from Terraform
  until explicit API load-balancer and Firebase allowlist resources are present.

## Runtime trust model

- Browser app traffic is hosted separately from this runtime stack.
- Browser API traffic reaches a single FastAPI backend Cloud Run service.
- Speech MP3 traffic is served from a private GCS bucket through a dedicated
  Cloud CDN hostname. The backend writes objects with its runtime service
  account and returns time-limited signed CDN URLs to browsers.
- Secret versions are pinned explicitly per environment; floating `latest` is not supported.
- Human admin routes are part of the backend API but require Google Firebase allowlist's
  signed JWT assertion and an explicit admin email allow-list. The plain Firebase allowlist
  email header is never trusted by the backend.

This decomposition follows HashiCorp guidance for system decomposition with separate root configurations and isolated state per component.

## Why this pattern

- Terraform CLI workspaces are not a substitute for decomposition or access-boundary isolation.
- Google Cloud guidance favors thin root configs, reusable modules, and explicit cross-config communication.
- Cloud SQL gets its own lifecycle and blast radius in a dedicated database component.

## Local development policy

Local app execution should not depend on Terraform.

- Run local app services from repo root: bash scripts/local/up.sh
- Terraform local env files are kept for optional parity experiments only.
- Terraform script blocks local by default unless TF_ALLOW_LOCAL=1.

## Environment model

Each component has explicit tfvars per environment:

- platform/variables/local.tfvars
- platform/variables/test.tfvars
- platform/variables/prod.tfvars
- database/variables/local.tfvars
- database/variables/test.tfvars
- database/variables/prod.tfvars
- runtime/variables/local.tfvars
- runtime/variables/test.tfvars
- runtime/variables/prod.tfvars

## State model

State prefix per component/environment:

- components/platform/local
- components/platform/test
- components/platform/prod
- components/database/local
- components/database/test
- components/database/prod
- components/runtime/local
- components/runtime/test
- components/runtime/prod

Provide backend bucket via:

- TF_STATE_BUCKET_LOCAL
- TF_STATE_BUCKET_TEST
- TF_STATE_BUCKET_PROD

## Commands

From terraform:

- bash scripts/tf-stack.sh platform test plan
- bash scripts/tf-stack.sh database test plan
- bash scripts/tf-stack.sh runtime test plan
- bash scripts/tf-stack.sh platform test apply
- bash scripts/tf-stack.sh database test apply
- bash scripts/tf-stack.sh runtime test apply

From repo root:

- `make terraform-fmt-check`
- `make terraform-validate`
- `make terraform-plan COMPONENT=platform ENV=test`
- `make terraform-plan COMPONENT=database ENV=test`
- `make terraform-plan COMPONENT=runtime ENV=test`

Apply order:

1. platform
2. database
3. runtime

Destroy order:

1. runtime
2. database
3. platform
