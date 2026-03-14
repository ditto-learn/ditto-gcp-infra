project_id                   = "ditto-local"
environment                  = "local"
www_domain                   = "www.dittolearn.local"
app_domain                   = "app.dittolearn.local"
api_domain                   = "api.dittolearn.local"
db_password                  = "local-password"
identity_platform_project_id = "ditto-local"
google_genai_api_key         = "replace-me"

container_images = {
  public_site  = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-public-site:local"
  web_app      = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-web-app:local"
  access       = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-access-service:local"
  learning     = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-learning-service:local"
  intelligence = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-intelligence-service:local"
  ai           = "europe-west2-docker.pkg.dev/ditto-local/ditto-containers/ditto-ai-engine:local"
}

cors_origins = {
  ai = ["http://localhost:5173"]
}
