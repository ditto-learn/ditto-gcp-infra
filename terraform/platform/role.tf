locals {
  service_accounts = {
    public_site  = "ditto-public-site-${var.environment}"
    web_app      = "ditto-web-app-${var.environment}"
    access       = "ditto-access-${var.environment}"
    learning     = "ditto-learning-${var.environment}"
    question     = "ditto-question-${var.environment}"
    intelligence = "ditto-intelligence-${var.environment}"
    ai           = "ditto-ai-${var.environment}"
    billing      = "ditto-billing-${var.environment}"
  }

  service_secret_access_pairs = [
    {
      key          = "ai:google-genai-api-key"
      service_name = "ai"
      secret_id    = google_secret_manager_secret.google_genai_api_key.secret_id
    },
    {
      key          = "question:google-genai-api-key"
      service_name = "question"
      secret_id    = google_secret_manager_secret.google_genai_api_key.secret_id
    },
    {
      key          = "billing:stripe-secret-key"
      service_name = "billing"
      secret_id    = google_secret_manager_secret.stripe_secret_key.secret_id
    },
    {
      key          = "billing:stripe-webhook-secret"
      service_name = "billing"
      secret_id    = google_secret_manager_secret.stripe_webhook_secret.secret_id
    },
  ]
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
    if contains(["access", "learning", "intelligence", "ai", "billing"], key)
  }

  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${each.value.email}"
}

resource "google_project_iam_member" "cloudsql_instance_user" {
  for_each = {
    for key, value in google_service_account.runtime :
    key => value
    if contains(["access", "learning", "intelligence", "ai", "billing"], key)
  }

  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${each.value.email}"
}

resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  for_each = {
    for pair in local.service_secret_access_pairs :
    pair.key => pair
  }

  project   = var.project_id
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.runtime[each.value.service_name].email}"
}
