resource "google_sql_database_instance" "main" {
  name             = "${var.db_instance_name}-${var.environment}"
  project          = var.project_id
  region           = var.region
  database_version = var.db_version

  settings {
    tier              = var.db_tier
    availability_type = "ZONAL"

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    # Public IP is enabled but no authorized_networks blocks are defined.
    # The instance is only reachable through the Cloud SQL Auth Proxy
    # using IAM authentication. SSL is enforced.
    ip_configuration {
      ipv4_enabled = true
      ssl_mode     = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled                        = var.db_backup_enabled
      point_in_time_recovery_enabled = var.db_pitr_enabled
      start_time                     = "03:00"
      transaction_log_retention_days = var.db_transaction_log_retention_days
    }
  }

  deletion_protection = var.db_deletion_protection
}

resource "google_sql_database" "main" {
  name     = var.db_name
  project  = var.project_id
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "runtime_iam" {
  for_each = {
    for key, value in data.terraform_remote_state.platform.outputs.service_account_emails :
    key => value
    if key == "backend"
  }

  project  = var.project_id
  instance = google_sql_database_instance.main.name
  name     = each.value
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}
