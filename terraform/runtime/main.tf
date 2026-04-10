locals {
  platform = data.terraform_remote_state.platform.outputs
  database = data.terraform_remote_state.database.outputs

  service_accounts = local.platform.service_account_emails
  secret_ids       = local.platform.secret_ids
  db_socket        = "/cloudsql/${local.database.cloud_sql_connection_name}"

  common_labels = {
    environment = var.environment
    managed_by  = "terraform"
    component   = "runtime"
    project     = "ditto"
  }
}

module "backend" {
  source = "../modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-backend-${var.environment}"
  region                = var.region
  image                 = var.container_images.backend
  port                  = 8080
  service_account_email = local.service_accounts.backend
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_ALL"
  min_instances         = var.api_min_instances
  deletion_protection   = var.service_deletion_protection
  cloud_sql_instances   = [local.database.cloud_sql_connection_name]
  labels                = local.common_labels
  secret_version        = var.secret_version
  plain_env = {
    APP_ENV                      = var.environment
    DB_CONNECTION_URL            = "postgresql://${replace(local.service_accounts.backend, "@", "%40")}@/${local.database.db_name}?host=${local.db_socket}"
    ASYNC_DB_CONNECTION_URL      = "postgresql+asyncpg://${replace(local.service_accounts.backend, "@", "%40")}@/${local.database.db_name}?host=${local.db_socket}"
    IDENTITY_PLATFORM_PROJECT_ID = var.identity_platform_project_id

    STRIPE_PRO_PRICE_ID         = var.stripe_pro_price_id
    STRIPE_CHECKOUT_SUCCESS_URL = var.stripe_checkout_success_url
    STRIPE_CHECKOUT_CANCEL_URL  = var.stripe_checkout_cancel_url
    STRIPE_PORTAL_RETURN_URL    = var.stripe_portal_return_url

    GOOGLE_CLOUD_PROJECT  = var.project_id
    GOOGLE_CLOUD_LOCATION = var.region
    APP_CORS_ORIGIN       = var.cors_origins.web

    REDIS__ENABLED = "false"
  }
  secret_env = {
    STRIPE_SECRET_KEY     = local.secret_ids.stripe_secret_key
    STRIPE_WEBHOOK_SECRET = local.secret_ids.stripe_webhook_secret
    GOOGLE_GENAI_API_KEY  = local.secret_ids.google_genai_api_key
    GOOGLE_API_KEY        = local.secret_ids.google_genai_api_key
    SENTRY_DSN            = local.secret_ids.sentry_dsn
  }
}
