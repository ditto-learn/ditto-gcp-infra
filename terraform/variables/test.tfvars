project_id                   = "replace-test-project"
environment                  = "test"
www_domain                   = "www-test.dittolearn.com"
app_domain                   = "app-test.dittolearn.com"
api_domain                   = "api-test.dittolearn.com"
db_password                  = "replace-test-password"
identity_platform_project_id = "replace-test-project"
google_genai_api_key         = "replace-test-genai-key"
local_service_token          = "replace-test-service-token"
stripe_secret_key            = "replace-test-stripe-secret"
stripe_webhook_secret        = "replace-test-stripe-webhook-secret"
stripe_pro_price_id          = "price_replace_test"
stripe_checkout_success_url  = "https://app-test.dittolearn.com/settings?billing=success"
stripe_checkout_cancel_url   = "https://app-test.dittolearn.com/settings?billing=cancel"
stripe_portal_return_url     = "https://app-test.dittolearn.com/settings"

container_images = {
  public_site  = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-public-site:test"
  web_app      = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-web-app:test"
  access       = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-access-service:test"
  learning     = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-learning-service:test"
  intelligence = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-intelligence-service:test"
  ai           = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-ai-engine:test"
  billing      = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-billing-service:test"
}

cors_origins = {
  ai = ["https://app-test.dittolearn.com"]
}
