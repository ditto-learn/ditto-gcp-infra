project_id                   = "ditto-prod"
environment                  = "prod"
region                       = "europe-west2"
www_domain                   = "www.dittolearn.com"
app_domain                   = "app.dittolearn.com"
api_domain                   = "api.dittolearn.com"
identity_platform_project_id = "ditto-prod"
stripe_pro_price_id          = "price_replace_prod"
stripe_checkout_success_url  = "https://app.dittolearn.com/settings?billing=success"
stripe_checkout_cancel_url   = "https://app.dittolearn.com/settings?billing=cancel"
stripe_portal_return_url     = "https://app.dittolearn.com/settings"
platform_state_bucket        = "ditto-tf-state-prod"
platform_state_prefix        = "components/platform/prod"
database_state_bucket        = "ditto-tf-state-prod"
database_state_prefix        = "components/database/prod"
manage_dns_records           = false
# Set when the domain is hosted in Cloud DNS and should be managed by Terraform.
# dns_managed_zone = "dittolearn-com"
# dns_project_id   = "ditto-prod"

container_images = {
  public_site  = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-public-site:prod"
  web_app      = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-web-app:prod"
  access       = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-access-service:prod"
  learning     = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-learning-service:prod"
  intelligence = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-intelligence-service:prod"
  ai           = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-ai-engine:prod"
  billing      = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-billing-service:prod"
}

cors_origins = {
  ai = "https://app.dittolearn.com"
}
