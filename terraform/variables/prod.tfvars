project_id                   = "replace-prod-project"
environment                  = "prod"
www_domain                   = "www.dittolearn.com"
app_domain                   = "app.dittolearn.com"
api_domain                   = "api.dittolearn.com"
db_password                  = "replace-prod-password"
identity_platform_project_id = "replace-prod-project"
google_genai_api_key         = "replace-prod-genai-key"
local_service_token          = "replace-prod-service-token"
stripe_secret_key            = "replace-prod-stripe-secret"
stripe_webhook_secret        = "replace-prod-stripe-webhook-secret"
stripe_pro_price_id          = "price_replace_prod"
stripe_checkout_success_url  = "https://app.dittolearn.com/settings?billing=success"
stripe_checkout_cancel_url   = "https://app.dittolearn.com/settings?billing=cancel"
stripe_portal_return_url     = "https://app.dittolearn.com/settings"

container_images = {
  public_site  = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-public-site:prod"
  web_app      = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-web-app:prod"
  access       = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-access-service:prod"
  learning     = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-learning-service:prod"
  intelligence = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-intelligence-service:prod"
  ai           = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-ai-engine:prod"
  billing      = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-billing-service:prod"
}

cors_origins = {
  ai = ["https://app.dittolearn.com"]
}
