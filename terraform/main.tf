locals {
  apis = toset([
    "artifactregistry.googleapis.com",
    "certificatemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ])

  db_connection_url   = "postgresql://${var.db_user}:${var.db_password}@/${var.db_name}?host=${local.db_socket}"
  session_service_uri = "postgresql+asyncpg://${var.db_user}:${var.db_password}@/${var.db_name}?host=${local.db_socket}"
}

resource "google_project_service" "enabled" {
  for_each = local.apis
  project  = var.project_id
  service  = each.key
}

resource "google_artifact_registry_repository" "containers" {
  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_registry_repository_id
  format        = "DOCKER"

  depends_on = [google_project_service.enabled]
}

resource "google_sql_database_instance" "main" {
  name             = "${var.db_instance_name}-${var.environment}"
  project          = var.project_id
  region           = var.region
  database_version = "POSTGRES_16"

  settings {
    tier              = "db-custom-1-3840"
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL"

    ip_configuration {
      ipv4_enabled    = true
      ssl_mode        = "ENCRYPTED_ONLY"
      private_network = null
    }

    backup_configuration {
      enabled = var.environment != "local"
    }
  }

  deletion_protection = var.environment == "prod"

  depends_on = [google_project_service.enabled]
}

resource "google_sql_database" "main" {
  name     = var.db_name
  project  = var.project_id
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app" {
  project  = var.project_id
  instance = google_sql_database_instance.main.name
  name     = var.db_user
  password = var.db_password
}

module "public_site" {
  source = "./modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-public-site-${var.environment}"
  region                = var.region
  image                 = var.container_images.public_site
  port                  = 3000
  service_account_email = google_service_account.runtime["public_site"].email
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  plain_env = {
    APP_ENV = var.environment
  }
}

module "web_app" {
  source = "./modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-web-app-${var.environment}"
  region                = var.region
  image                 = var.container_images.web_app
  port                  = 8080
  service_account_email = google_service_account.runtime["web_app"].email
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  plain_env = {
    APP_ENV = var.environment
  }
}

module "access_service" {
  source = "./modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-access-service-${var.environment}"
  region                = var.region
  image                 = var.container_images.access
  port                  = 8080
  service_account_email = google_service_account.runtime["access"].email
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  cloud_sql_instances   = [google_sql_database_instance.main.connection_name]
  plain_env = {
    APP_ENV                      = var.environment
    DB_CONNECTION_URL            = local.db_connection_url
    IDENTITY_PLATFORM_PROJECT_ID = var.identity_platform_project_id
  }
}

module "learning_service" {
  source = "./modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-learning-service-${var.environment}"
  region                = var.region
  image                 = var.container_images.learning
  port                  = 8080
  service_account_email = google_service_account.runtime["learning"].email
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  cloud_sql_instances   = [google_sql_database_instance.main.connection_name]
  plain_env = {
    APP_ENV                  = var.environment
    DB_CONNECTION_URL        = local.db_connection_url
    ACCESS_SERVICE_URL       = "https://${var.api_domain}/access"
    INTELLIGENCE_SERVICE_URL = "https://${var.api_domain}/intelligence"
    AI_SERVICE_URL           = "https://${var.api_domain}/ai"
  }
}

module "intelligence_service" {
  source = "./modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-intelligence-service-${var.environment}"
  region                = var.region
  image                 = var.container_images.intelligence
  port                  = 8080
  service_account_email = google_service_account.runtime["intelligence"].email
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  cloud_sql_instances   = [google_sql_database_instance.main.connection_name]
  plain_env = {
    APP_ENV                      = var.environment
    DB_CONNECTION_URL            = local.db_connection_url
    IDENTITY_PLATFORM_PROJECT_ID = var.identity_platform_project_id
  }
}

module "ai_service" {
  source = "./modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-ai-engine-${var.environment}"
  region                = var.region
  image                 = var.container_images.ai
  port                  = 8000
  service_account_email = google_service_account.runtime["ai"].email
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  cloud_sql_instances   = [google_sql_database_instance.main.connection_name]
  plain_env = {
    APP_ENV                      = var.environment
    DB_CONNECTION_URL            = local.db_connection_url
    SESSION_SERVICE_URI          = local.session_service_uri
    ACCESS_SERVICE_URL           = "https://${var.api_domain}/access"
    INTELLIGENCE_SERVICE_URL     = "https://${var.api_domain}/intelligence"
    IDENTITY_PLATFORM_PROJECT_ID = var.identity_platform_project_id
    APP_CORS_ORIGIN              = one(var.cors_origins.ai)
    GOOGLE_GENAI_API_KEY         = var.google_genai_api_key
  }
}

resource "google_compute_region_network_endpoint_group" "serverless" {
  for_each = {
    public_site  = module.public_site.service_name
    web_app      = module.web_app.service_name
    access       = module.access_service.service_name
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
      paths   = ["/learning", "/learning/*"]
      service = google_compute_backend_service.edge["learning"].id
    }

    path_rule {
      paths   = ["/intelligence", "/intelligence/*"]
      service = google_compute_backend_service.edge["intelligence"].id
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
