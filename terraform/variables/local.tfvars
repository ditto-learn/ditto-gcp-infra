project_id                   = "ditto-local"
environment                  = "local"
www_domain                   = "www.dittolearn.local"
app_domain                   = "app.dittolearn.local"
api_domain                   = "api.dittolearn.local"
identity_platform_project_id = "ditto-local"
stripe_pro_price_id          = "price_replace_local"
stripe_checkout_success_url  = "http://localhost:5173/settings?billing=success"
stripe_checkout_cancel_url   = "http://localhost:5173/settings?billing=cancel"
stripe_portal_return_url     = "http://localhost:5173/settings"

container_images = {
  public_site  = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-public-site:local"
  web_app      = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-web-app:local"
  access       = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-access-service:local"
  learning     = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-learning-service:local"
  intelligence = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-intelligence-service:local"
  ai           = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-ai-engine:local"
  billing      = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-billing-service:local"
}

cors_origins = {
  ai = ["http://localhost:5173"]
}
