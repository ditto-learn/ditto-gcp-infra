project_id                   = "ditto-prod"
environment                  = "prod"
region                       = "europe-west2"
www_domain                   = "www.dittolearn.com"
app_domain                   = "app.dittolearn.com"
api_domain                   = "api.dittolearn.com"
identity_platform_project_id = "ditto-prod"
stripe_pro_price_id          = "price_replace_prod"
stripe_checkout_success_url  = "https://app.dittolearn.com/app/settings?billing=success"
stripe_checkout_cancel_url   = "https://app.dittolearn.com/app/settings?billing=cancel"
stripe_portal_return_url     = "https://app.dittolearn.com/app/settings"
platform_state_bucket        = "ditto-tf-state-prod"
platform_state_prefix        = "components/platform/prod"
database_state_bucket        = "ditto-tf-state-prod"
database_state_prefix        = "components/database/prod"
secret_version               = "1"
manage_dns_records           = false
# Set when the domain is hosted in Cloud DNS and should be managed by Terraform.
# dns_managed_zone = "dittolearn-com"
# dns_project_id   = "ditto-prod"

container_images = {
  web_app = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-web-app:prod"
  backend = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-backend:prod"
}

cors_origins = {
  ai = "https://app.dittolearn.com"
}

api_min_instances           = 1
service_deletion_protection = true
redis_tier                  = "STANDARD_HA"
alert_email                 = "engineering@dittolearn.com"
monthly_budget_amount       = 500
billing_account             = "REPLACE-WITH-BILLING-ACCOUNT-ID"

# Container images should be pinned to SHA digests in CI for reproducible deployments:
# backend = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-backend@sha256:..."
