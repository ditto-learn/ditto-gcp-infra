# Terraform Components

This directory is the only supported Terraform entrypoint for GCP infrastructure.

## Component model

- platform: APIs, VPC/NAT, Artifact Registry, service accounts, IAM, secrets, audit configs
- database: private service networking + Cloud SQL instance/database/users
- runtime: Cloud Run services, service-to-service invoker IAM, global HTTPS load balancer, host/path routing

## Runtime trust model

- Browser traffic enters through the external HTTPS load balancer.
- Internal service-to-service traffic uses direct Cloud Run service URIs.
- Cloud Run invoker IAM is derived from one declared dependency graph in `runtime/main.tf`.
- Secret versions are pinned explicitly per environment; floating `latest` is not supported.

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
