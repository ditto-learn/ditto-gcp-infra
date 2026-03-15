# Terraform Layout

This stack provisions the shared Google-native Ditto platform:

- `www.dittolearn.com` -> `ditto-public-site` on Cloud Run
- `app.dittolearn.com` -> `ditto-web-app` on Cloud Run behind nginx
- `api.dittolearn.com` -> path-routed Cloud Run backend services
- global external Application Load Balancer
- Cloud CDN for `www` and `app`
- Identity Platform for end-user auth
- Cloud SQL PostgreSQL as the only database

## Files

- `providers.tf`
  - Google provider and Terraform version pin
- `data.tf`
  - project/client data lookups
- `variables.tf`
  - root inputs
- `role.tf`
  - runtime service accounts and shared IAM
- `main.tf`
  - APIs, Artifact Registry, Cloud SQL, Cloud Run services, ALB, CDN
- `outputs.tf`
  - edge and database outputs
- `variables/*.tfvars`
  - example environment values for local, test, and prod

## Routing

- `www.dittolearn.com` -> `ditto-public-site`
- `app.dittolearn.com` -> `ditto-web-app`
- `api.dittolearn.com/access/*` -> `ditto-access-service`
- `api.dittolearn.com/learning/*` -> `ditto-learning-service`
- `api.dittolearn.com/intelligence/*` -> `ditto-intelligence-service`
- `api.dittolearn.com/ai/*` -> `ditto-ai-engine`

## Notes

- This root stack owns shared infra. App repos keep lightweight deployment-contract Terraform only; they do not create duplicate Cloud Run resources.
- The runtime stack is Cloud Run, Identity Platform, and Cloud SQL only, with no extra backend products layered in.
- Memorystore is intentionally not provisioned because no active runtime service currently requires Redis.
- Local values are illustrative only; local development should still run directly with local commands and env-specific YAML config.
- Secret Manager access is least privilege. Grant per-service secret IDs through `service_secret_ids` instead of project-wide accessor roles.
- Frontend Cloud Run services (`public-site`, `web-app`) are configured with `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER` and no direct `allUsers` invoker grant. Public access is via the external HTTPS load balancer only.
- Cloud SQL IAM authentication is enabled and runtime service accounts are provisioned as IAM database users (`roles/cloudsql.instanceUser`). Services use IAM-auth database URIs directly and no password-based DB auth path is provisioned in Terraform.
- Service-to-service local shared-token shims are removed. Internal trust is defined through Cloud Run IAM invoker bindings and platform identity.
