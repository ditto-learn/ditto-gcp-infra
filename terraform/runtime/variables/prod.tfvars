project_id                        = "ditto-prod"
environment                       = "prod"
region                            = "europe-west2"
identity_platform_project_id      = "ditto-prod"
identity_platform_username_domain = "learners.dittolearn.com"
stripe_family_pro_price_id        = "price_replace_prod"
stripe_checkout_success_url       = "https://app.dittolearn.com/app/settings?billing=success"
stripe_checkout_cancel_url        = "https://app.dittolearn.com/app/settings?billing=cancel"
stripe_portal_return_url          = "https://app.dittolearn.com/app/settings"
platform_state_bucket             = "ditto-tf-state-prod"
platform_state_prefix             = "components/platform/prod"
database_state_bucket             = "ditto-tf-state-prod"
database_state_prefix             = "components/database/prod"
secret_version                    = "1"

container_images = {
  backend = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-backend:prod"
}

cors_origins = {
  web = "https://app.dittolearn.com"
}

api_allowed_hosts    = "api.dittolearn.com"
web_app_url          = "https://app.dittolearn.com"
admin_allowed_emails = "engineering@dittolearn.com"

cloud_tasks_service_base_url = "https://api.dittolearn.com"
speech_cdn_domain            = "speech.dittolearn.com"

api_min_instances           = 0
service_deletion_protection = true
alert_email                 = "engineering@dittolearn.com"
monthly_budget_amount       = 50
billing_account             = "REPLACE-WITH-BILLING-ACCOUNT-ID"

# Container images should be pinned to SHA digests in CI for reproducible deployments:
# backend = "europe-west2-docker.pkg.dev/ditto-prod/ditto-containers/ditto-backend@sha256:..."
