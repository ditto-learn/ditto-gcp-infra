project_id                   = "replace-test-project"
environment                  = "test"
www_domain                   = "www-test.dittolearn.com"
app_domain                   = "app-test.dittolearn.com"
api_domain                   = "api-test.dittolearn.com"
db_password                  = "replace-test-password"
identity_platform_project_id = "replace-test-project"
google_genai_api_key         = "replace-test-genai-key"

container_images = {
  public_site  = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-public-site:test"
  web_app      = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-web-app:test"
  access       = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-access-service:test"
  learning     = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-learning-service:test"
  intelligence = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-intelligence-service:test"
  ai           = "europe-west2-docker.pkg.dev/replace-test-project/ditto-containers/ditto-ai-engine:test"
}

cors_origins = {
  ai = ["https://app-test.dittolearn.com"]
}
