project_id                   = "ditto-local"
environment                  = "local"
region                       = "europe-west2"
www_domain                   = "www.dittolearn.local"
app_domain                   = "app.dittolearn.local"
api_domain                   = "api.dittolearn.local"
identity_platform_project_id = "ditto-local"
stripe_pro_price_id          = "price_replace_local"
stripe_checkout_success_url  = "http://localhost:5173/app/settings?billing=success"
stripe_checkout_cancel_url   = "http://localhost:5173/app/settings?billing=cancel"
stripe_portal_return_url     = "http://localhost:5173/app/settings"
platform_state_bucket        = "ditto-tf-state-local"
platform_state_prefix        = "components/platform/local"
database_state_bucket        = "ditto-tf-state-local"
database_state_prefix        = "components/database/local"
secret_version               = "1"
manage_dns_records           = false
# Set when the domain is hosted in Cloud DNS and should be managed by Terraform.
# dns_managed_zone = "dittolearn-local"
# dns_project_id   = "ditto-local"

container_images = {
  web_app = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-web-app:local"
  backend = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-backend:local"
}

cors_origins = {
  ai = "http://localhost:5173"
}
