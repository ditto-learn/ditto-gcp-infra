project_id                   = "ditto-test"
environment                  = "test"
region                       = "europe-west2"
www_domain                   = "www-test.dittolearn.com"
app_domain                   = "app-test.dittolearn.com"
api_domain                   = "api-test.dittolearn.com"
identity_platform_project_id = "ditto-test"
stripe_pro_price_id          = "price_replace_test"
stripe_checkout_success_url  = "https://app-test.dittolearn.com/app/settings?billing=success"
stripe_checkout_cancel_url   = "https://app-test.dittolearn.com/app/settings?billing=cancel"
stripe_portal_return_url     = "https://app-test.dittolearn.com/app/settings"
platform_state_bucket        = "ditto-tf-state-test"
platform_state_prefix        = "components/platform/test"
database_state_bucket        = "ditto-tf-state-test"
database_state_prefix        = "components/database/test"
secret_version               = "1"
manage_dns_records           = false
# Set when the domain is hosted in Cloud DNS and should be managed by Terraform.
# dns_managed_zone = "dittolearn-com"
# dns_project_id   = "ditto-test"

container_images = {
  web_app = "europe-west2-docker.pkg.dev/ditto-test/ditto-containers/ditto-web-app:test"
  backend = "europe-west2-docker.pkg.dev/ditto-test/ditto-containers/ditto-backend:test"
}

cors_origins = {
  ai = "https://app-test.dittolearn.com"
}

api_min_instances           = 0
service_deletion_protection = false
redis_tier                  = "BASIC"
alert_email                 = "engineering@dittolearn.com"
monthly_budget_amount       = 200
billing_account             = "REPLACE-WITH-BILLING-ACCOUNT-ID"
