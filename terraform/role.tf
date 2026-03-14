locals {
  service_accounts = {
    public_site  = "ditto-public-site-${var.environment}"
    web_app      = "ditto-web-app-${var.environment}"
    access       = "ditto-access-${var.environment}"
    learning     = "ditto-learning-${var.environment}"
    intelligence = "ditto-intelligence-${var.environment}"
    ai           = "ditto-ai-${var.environment}"
  }

  db_socket = "/cloudsql/${google_sql_database_instance.main.connection_name}"
}

resource "google_service_account" "runtime" {
  for_each = local.service_accounts

  project      = var.project_id
  account_id   = each.value
  display_name = each.value
}

resource "google_project_iam_member" "cloudsql_client" {
  for_each = {
    for key, value in google_service_account.runtime :
    key => value
    if contains(["access", "learning", "intelligence", "ai"], key)
  }

  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${each.value.email}"
}

resource "google_project_iam_member" "secret_accessor" {
  for_each = {
    for key, value in google_service_account.runtime :
    key => value
    if contains(["access", "learning", "intelligence", "ai"], key)
  }

  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${each.value.email}"
}
