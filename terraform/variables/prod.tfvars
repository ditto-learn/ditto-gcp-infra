project_id                   = "replace-prod-project"
environment                  = "prod"
www_domain                   = "www.dittolearn.com"
app_domain                   = "app.dittolearn.com"
api_domain                   = "api.dittolearn.com"
db_password                  = "replace-prod-password"
identity_platform_project_id = "replace-prod-project"
google_genai_api_key         = "replace-prod-genai-key"

container_images = {
  public_site  = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-public-site:prod"
  web_app      = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-web-app:prod"
  access       = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-access-service:prod"
  learning     = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-learning-service:prod"
  intelligence = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-intelligence-service:prod"
  ai           = "europe-west2-docker.pkg.dev/replace-prod-project/ditto-containers/ditto-ai-engine:prod"
}

cors_origins = {
  public_site  = ["https://www.dittolearn.com"]
  web_app      = ["https://app.dittolearn.com"]
  access       = ["https://app.dittolearn.com"]
  learning     = ["https://app.dittolearn.com"]
  intelligence = ["https://app.dittolearn.com"]
  ai           = ["https://app.dittolearn.com"]
}
