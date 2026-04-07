locals {
  platform = data.terraform_remote_state.platform.outputs
  database = data.terraform_remote_state.database.outputs

  service_accounts = local.platform.service_account_emails
  secret_ids       = local.platform.secret_ids
  db_socket        = "/cloudsql/${local.database.cloud_sql_connection_name}"

  dns_enabled = var.manage_dns_records && var.dns_managed_zone != null
  dns_records = local.dns_enabled ? {
    (var.www_domain) = "www"
    (var.app_domain) = "app"
    (var.api_domain) = "api"
  } : {}

  common_labels = {
    environment = var.environment
    managed_by  = "terraform"
    component   = "runtime"
    project     = "ditto"
  }
}

check "dns_configuration" {
  assert {
    condition     = !var.manage_dns_records || var.dns_managed_zone != null
    error_message = "dns_managed_zone must be set when manage_dns_records is true."
  }
}

module "web_app" {
  source = "../modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-web-app-${var.environment}"
  region                = var.region
  image                 = var.container_images.web_app
  port                  = 8080
  service_account_email = local.service_accounts.web_app
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  min_instances         = 0
  deletion_protection   = var.service_deletion_protection
  network_id            = local.platform.vpc_id
  subnetwork_id         = local.platform.subnet_id
  labels                = local.common_labels
  secret_version        = var.secret_version
  plain_env = {
    APP_ENV = var.environment
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
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  min_instances         = var.api_min_instances
  deletion_protection   = var.service_deletion_protection
  network_id            = local.platform.vpc_id
  subnetwork_id         = local.platform.subnet_id
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
    APP_CORS_ORIGIN       = var.cors_origins.ai

    REDIS_HOST = google_redis_instance.rate_limit.host
    REDIS_PORT = tostring(google_redis_instance.rate_limit.port)
  }
  secret_env = {
    STRIPE_SECRET_KEY     = local.secret_ids.stripe_secret_key
    STRIPE_WEBHOOK_SECRET = local.secret_ids.stripe_webhook_secret
    GOOGLE_GENAI_API_KEY  = local.secret_ids.google_genai_api_key
    GOOGLE_API_KEY        = local.secret_ids.google_genai_api_key
    SENTRY_DSN            = local.secret_ids.sentry_dsn
  }
}

resource "google_compute_region_network_endpoint_group" "serverless" {
  for_each = {
    web_app = module.web_app.service_name
    backend = module.backend.service_name
  }

  project               = var.project_id
  name                  = "neg-${each.key}-${var.environment}"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = each.value
  }
}

resource "google_compute_backend_service" "edge" {
  for_each              = google_compute_region_network_endpoint_group.serverless
  name                  = "backend-${each.key}-${var.environment}"
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTPS"
  enable_cdn            = each.key == "web_app"
  security_policy       = each.key == "backend" ? google_compute_security_policy.api.id : null

  backend {
    group = each.value.id
  }
}

resource "google_compute_managed_ssl_certificate" "edge" {
  project = var.project_id
  name    = "ditto-edge-${var.environment}"

  managed {
    domains = [var.www_domain, var.app_domain, var.api_domain]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_url_map" "edge" {
  project         = var.project_id
  name            = "ditto-edge-${var.environment}"
  default_service = google_compute_backend_service.edge["web_app"].id

  host_rule {
    hosts        = [var.www_domain]
    path_matcher = "www"
  }

  host_rule {
    hosts        = [var.app_domain]
    path_matcher = "app"
  }

  host_rule {
    hosts        = [var.api_domain]
    path_matcher = "api"
  }

  path_matcher {
    name            = "www"
    default_service = google_compute_backend_service.edge["web_app"].id
  }

  path_matcher {
    name            = "app"
    default_service = google_compute_backend_service.edge["web_app"].id
  }

  path_matcher {
    name            = "api"
    default_service = google_compute_backend_service.edge["backend"].id
  }
}

resource "google_compute_target_https_proxy" "edge" {
  project          = var.project_id
  name             = "ditto-edge-${var.environment}"
  url_map          = google_compute_url_map.edge.id
  ssl_certificates = [google_compute_managed_ssl_certificate.edge.id]
}

resource "google_compute_global_address" "edge" {
  project = var.project_id
  name    = "ditto-edge-${var.environment}"
}

resource "google_compute_global_forwarding_rule" "edge" {
  project               = var.project_id
  name                  = "ditto-edge-${var.environment}"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.edge.id
  ip_address            = google_compute_global_address.edge.id
}

resource "google_dns_record_set" "edge_a_record" {
  for_each = local.dns_records

  project      = coalesce(var.dns_project_id, var.project_id)
  managed_zone = var.dns_managed_zone
  name         = "${each.key}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.edge.address]
}

resource "google_compute_url_map" "http_redirect" {
  project = var.project_id
  name    = "ditto-http-redirect-${var.environment}"

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  project = var.project_id
  name    = "ditto-http-redirect-${var.environment}"
  url_map = google_compute_url_map.http_redirect.id
}

resource "google_compute_global_forwarding_rule" "http_redirect" {
  project               = var.project_id
  name                  = "ditto-http-redirect-${var.environment}"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.redirect.id
  ip_address            = google_compute_global_address.edge.id
}
