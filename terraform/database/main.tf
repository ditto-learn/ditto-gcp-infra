locals {
  platform = data.terraform_remote_state.platform.outputs
}

resource "google_compute_global_address" "private_ip_range" {
  name          = "private-ip-range-${var.environment}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = local.platform.vpc_id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc" {
  network                 = local.platform.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

resource "google_sql_database_instance" "main" {
  name             = "${var.db_instance_name}-${var.environment}"
  project          = var.project_id
  region           = var.region
  database_version = var.db_version

  settings {
    tier              = var.db_tier
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL"

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    ip_configuration {
      ipv4_enabled                                  = false
      ssl_mode                                      = "ENCRYPTED_ONLY"
      private_network                               = local.platform.vpc_id
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = var.environment != "local"
      point_in_time_recovery_enabled = var.environment != "local"
      start_time                     = "03:00"
      transaction_log_retention_days = var.environment == "prod" ? 7 : 3
    }
  }

  deletion_protection = var.environment == "prod"

  depends_on = [google_service_networking_connection.private_vpc]
}

resource "google_sql_database" "main" {
  name     = var.db_name
  project  = var.project_id
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "runtime_iam" {
  for_each = {
    for key, value in local.platform.service_account_emails :
    key => value
    if contains(["access", "learning", "intelligence", "ai", "billing"], key)
  }

  project  = var.project_id
  instance = google_sql_database_instance.main.name
  name     = each.value
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}
