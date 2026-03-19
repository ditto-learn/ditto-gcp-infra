locals {
  platform = data.terraform_remote_state.platform.outputs
  database = data.terraform_remote_state.database.outputs

  service_accounts = local.platform.service_account_emails
  secret_ids       = local.platform.secret_ids
  db_socket        = "/cloudsql/${local.database.cloud_sql_connection_name}"

  api_min_instances      = var.environment == "prod" ? 1 : 0
  frontend_min_instances = 0

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

module "public_site" {
  source = "../modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-public-site-${var.environment}"
  region                = var.region
  image                 = var.container_images.public_site
  port                  = 3000
  service_account_email = local.service_accounts.public_site
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  min_instances         = local.frontend_min_instances
  deletion_protection   = var.environment == "prod"
  network_id            = local.platform.vpc_id
  subnetwork_id         = local.platform.subnet_id
  labels                = local.common_labels
  secret_version        = var.secret_version
  plain_env = {
    APP_ENV = var.environment
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
  min_instances         = local.frontend_min_instances
  deletion_protection   = var.environment == "prod"
  network_id            = local.platform.vpc_id
  subnetwork_id         = local.platform.subnet_id
  labels                = local.common_labels
  secret_version        = var.secret_version
  plain_env = {
    APP_ENV = var.environment
  }
}

module "access_service" {
  source = "../modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-access-service-${var.environment}"
  region                = var.region
  image                 = var.container_images.access
  port                  = 8080
  service_account_email = local.service_accounts.access
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  min_instances         = local.api_min_instances
  deletion_protection   = var.environment == "prod"
  network_id            = local.platform.vpc_id
  subnetwork_id         = local.platform.subnet_id
  cloud_sql_instances   = [local.database.cloud_sql_connection_name]
  labels                = local.common_labels
  secret_version        = var.secret_version
  plain_env = {
    APP_ENV                      = var.environment
    DB_CONNECTION_URL            = "postgresql://${replace(local.service_accounts.access, "@", "%40")}@/${local.database.db_name}?host=${local.db_socket}"
    IDENTITY_PLATFORM_PROJECT_ID = var.identity_platform_project_id
    ACCESS_ALLOWED_SERVICE_ACCOUNTS = join(
      ",",
      [
        local.service_accounts.billing,
        local.service_accounts.learning,
        local.service_accounts.intelligence,
        local.service_accounts.ai,
      ],
    )
  }
}

module "billing_service" {
  source = "../modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-billing-service-${var.environment}"
  region                = var.region
  image                 = var.container_images.billing
  port                  = 8080
  service_account_email = local.service_accounts.billing
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  min_instances         = local.api_min_instances
  deletion_protection   = var.environment == "prod"
  network_id            = local.platform.vpc_id
  subnetwork_id         = local.platform.subnet_id
  cloud_sql_instances   = [local.database.cloud_sql_connection_name]
  labels                = local.common_labels
  secret_version        = var.secret_version
  plain_env = {
    APP_ENV                      = var.environment
    DB_CONNECTION_URL            = "postgresql://${replace(local.service_accounts.billing, "@", "%40")}@/${local.database.db_name}?host=${local.db_socket}"
    IDENTITY_PLATFORM_PROJECT_ID = var.identity_platform_project_id
    ACCESS_SERVICE_URL           = module.access_service.uri
    STRIPE_PRO_PRICE_ID          = var.stripe_pro_price_id
    STRIPE_CHECKOUT_SUCCESS_URL  = var.stripe_checkout_success_url
    STRIPE_CHECKOUT_CANCEL_URL   = var.stripe_checkout_cancel_url
    STRIPE_PORTAL_RETURN_URL     = var.stripe_portal_return_url
  }
  secret_env = {
    STRIPE_SECRET_KEY     = local.secret_ids.stripe_secret_key
    STRIPE_WEBHOOK_SECRET = local.secret_ids.stripe_webhook_secret
  }
}

module "learning_service" {
  source = "../modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-learning-service-${var.environment}"
  region                = var.region
  image                 = var.container_images.learning
  port                  = 8080
  service_account_email = local.service_accounts.learning
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  min_instances         = local.api_min_instances
  deletion_protection   = var.environment == "prod"
  network_id            = local.platform.vpc_id
  subnetwork_id         = local.platform.subnet_id
  cloud_sql_instances   = [local.database.cloud_sql_connection_name]
  labels                = local.common_labels
  secret_version        = var.secret_version
  plain_env = {
    APP_ENV                           = var.environment
    DB_CONNECTION_URL                 = "postgresql://${replace(local.service_accounts.learning, "@", "%40")}@/${local.database.db_name}?host=${local.db_socket}"
    ACCESS_SERVICE_URL                = module.access_service.uri
    BILLING_SERVICE_URL               = module.billing_service.uri
    QUESTION_SERVICE_URL              = module.question_service.uri
    INTELLIGENCE_SERVICE_URL          = module.intelligence_service.uri
    LEARNING_ALLOWED_SERVICE_ACCOUNTS = local.service_accounts.ai
  }
}

module "question_service" {
  source = "../modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-question-service-${var.environment}"
  region                = var.region
  image                 = var.container_images.question
  port                  = 8080
  service_account_email = local.service_accounts.question
  invoker_member        = null
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  min_instances         = local.api_min_instances
  deletion_protection   = var.environment == "prod"
  network_id            = local.platform.vpc_id
  subnetwork_id         = local.platform.subnet_id
  labels                = local.common_labels
  secret_version        = var.secret_version
  plain_env = {
    APP_ENV                           = var.environment
    QUESTION_ALLOWED_SERVICE_ACCOUNTS = local.service_accounts.learning
  }
  secret_env = {
    GOOGLE_GENAI_API_KEY = local.secret_ids.google_genai_api_key
  }
}

module "intelligence_service" {
  source = "../modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-intelligence-service-${var.environment}"
  region                = var.region
  image                 = var.container_images.intelligence
  port                  = 8080
  service_account_email = local.service_accounts.intelligence
  invoker_member        = null
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  min_instances         = local.api_min_instances
  deletion_protection   = var.environment == "prod"
  network_id            = local.platform.vpc_id
  subnetwork_id         = local.platform.subnet_id
  cloud_sql_instances   = [local.database.cloud_sql_connection_name]
  labels                = local.common_labels
  secret_version        = var.secret_version
  plain_env = {
    APP_ENV                      = var.environment
    DB_CONNECTION_URL            = "postgresql://${replace(local.service_accounts.intelligence, "@", "%40")}@/${local.database.db_name}?host=${local.db_socket}"
    ACCESS_SERVICE_URL           = module.access_service.uri
    IDENTITY_PLATFORM_PROJECT_ID = var.identity_platform_project_id
    INTELLIGENCE_ALLOWED_SERVICE_ACCOUNTS = join(
      ",",
      [
        local.service_accounts.learning,
        local.service_accounts.ai,
      ],
    )
  }
}

module "ai_service" {
  source = "../modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-ai-engine-${var.environment}"
  region                = var.region
  image                 = var.container_images.ai
  port                  = 8000
  service_account_email = local.service_accounts.ai
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  min_instances         = local.api_min_instances
  deletion_protection   = var.environment == "prod"
  network_id            = local.platform.vpc_id
  subnetwork_id         = local.platform.subnet_id
  cloud_sql_instances   = [local.database.cloud_sql_connection_name]
  labels                = local.common_labels
  secret_version        = var.secret_version
  plain_env = {
    APP_ENV                      = var.environment
    DB_CONNECTION_URL            = "postgresql://${replace(local.service_accounts.ai, "@", "%40")}@/${local.database.db_name}?host=${local.db_socket}"
    SESSION_SERVICE_URI          = "postgresql+asyncpg://${replace(local.service_accounts.ai, "@", "%40")}@/${local.database.db_name}?host=${local.db_socket}"
    ACCESS_SERVICE_URL           = module.access_service.uri
    LEARNING_SERVICE_URL         = module.learning_service.uri
    INTELLIGENCE_SERVICE_URL     = module.intelligence_service.uri
    IDENTITY_PLATFORM_PROJECT_ID = var.identity_platform_project_id
    APP_CORS_ORIGIN              = var.cors_origins.ai
  }
  secret_env = {
    GOOGLE_GENAI_API_KEY = local.secret_ids.google_genai_api_key
  }
}

locals {
  internal_service_dependencies = {
    learning     = ["access", "billing", "question", "intelligence"]
    ai           = ["access", "learning", "intelligence"]
    billing      = ["access"]
    intelligence = ["access"]
  }

  internal_service_names = {
    access       = module.access_service.service_name
    billing      = module.billing_service.service_name
    learning     = module.learning_service.service_name
    question     = module.question_service.service_name
    intelligence = module.intelligence_service.service_name
    ai           = module.ai_service.service_name
  }

  service_invoker_edges = merge([
    for caller, targets in local.internal_service_dependencies : {
      for target in targets :
      "${caller}_to_${target}" => {
        caller = caller
        target = local.internal_service_names[target]
      }
    }
  ]...)
}

resource "google_cloud_run_v2_service_iam_member" "service_invoker" {
  for_each = local.service_invoker_edges

  project  = var.project_id
  location = var.region
  name     = each.value.target
  role     = "roles/run.invoker"
  member   = "serviceAccount:${local.service_accounts[each.value.caller]}"
}

resource "google_compute_region_network_endpoint_group" "serverless" {
  for_each = {
    public_site  = module.public_site.service_name
    web_app      = module.web_app.service_name
    access       = module.access_service.service_name
    billing      = module.billing_service.service_name
    learning     = module.learning_service.service_name
    intelligence = module.intelligence_service.service_name
    ai           = module.ai_service.service_name
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
  enable_cdn            = contains(["public_site", "web_app"], each.key)

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
}

resource "google_compute_url_map" "edge" {
  project         = var.project_id
  name            = "ditto-edge-${var.environment}"
  default_service = google_compute_backend_service.edge["public_site"].id

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
    default_service = google_compute_backend_service.edge["public_site"].id
  }

  path_matcher {
    name            = "app"
    default_service = google_compute_backend_service.edge["web_app"].id
  }

  path_matcher {
    name            = "api"
    default_service = google_compute_backend_service.edge["access"].id

    path_rule {
      paths   = ["/access", "/access/*"]
      service = google_compute_backend_service.edge["access"].id
    }

    path_rule {
      paths   = ["/billing", "/billing/*"]
      service = google_compute_backend_service.edge["billing"].id
    }

    path_rule {
      paths   = ["/learning", "/learning/*"]
      service = google_compute_backend_service.edge["learning"].id
    }

    path_rule {
      paths   = ["/ai", "/ai/*"]
      service = google_compute_backend_service.edge["ai"].id
    }
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
