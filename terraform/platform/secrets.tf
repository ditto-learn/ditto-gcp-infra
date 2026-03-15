resource "google_secret_manager_secret" "google_genai_api_key" {
  secret_id = "ditto-${var.environment}-google-genai-api-key"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret_version" "google_genai_api_key" {
  secret      = google_secret_manager_secret.google_genai_api_key.id
  secret_data = var.google_genai_api_key
}

resource "google_secret_manager_secret" "stripe_secret_key" {
  secret_id = "ditto-${var.environment}-stripe-secret-key"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret_version" "stripe_secret_key" {
  secret      = google_secret_manager_secret.stripe_secret_key.id
  secret_data = var.stripe_secret_key
}

resource "google_secret_manager_secret" "stripe_webhook_secret" {
  secret_id = "ditto-${var.environment}-stripe-webhook-secret"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret_version" "stripe_webhook_secret" {
  secret      = google_secret_manager_secret.stripe_webhook_secret.id
  secret_data = var.stripe_webhook_secret
}
