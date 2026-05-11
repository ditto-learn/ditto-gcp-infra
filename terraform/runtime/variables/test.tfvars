project_id                        = "ditto-test"
environment                       = "test"
region                            = "europe-west2"
identity_platform_project_id      = "ditto-test"
identity_platform_username_domain = "learners-test.dittolearn.com"
stripe_family_pro_price_id        = "price_replace_test"
stripe_checkout_success_url       = "https://app-test.dittolearn.com/app/settings?billing=success"
stripe_checkout_cancel_url        = "https://app-test.dittolearn.com/app/settings?billing=cancel"
stripe_portal_return_url          = "https://app-test.dittolearn.com/app/settings"
platform_state_bucket             = "ditto-tf-state-test"
platform_state_prefix             = "components/platform/test"
database_state_bucket             = "ditto-tf-state-test"
database_state_prefix             = "components/database/test"
secret_version                    = "1"

container_images = {
  backend = "europe-west2-docker.pkg.dev/ditto-test/ditto-containers/ditto-backend:test"
}

cors_origins = {
  web = "https://app-test.dittolearn.com"
}

api_allowed_hosts    = "api-test.dittolearn.com"
web_app_url          = "https://app-test.dittolearn.com"
admin_allowed_emails = "engineering@dittolearn.com"
email_from_address   = "Nook <hello@dittolearn.com>"

cloud_tasks_service_base_url = "https://api-test.dittolearn.com"
speech_cdn_domain            = "speech-test.dittolearn.com"

api_min_instances           = 0
service_deletion_protection = false
alert_email                 = "engineering@dittolearn.com"
monthly_budget_amount       = 30
billing_account             = "REPLACE-WITH-BILLING-ACCOUNT-ID"
