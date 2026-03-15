resource "google_secret_manager_secret" "google_genai_api_key" {
  secret_id = "ditto-${var.environment}-google-genai-api-key"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret" "stripe_secret_key" {
  secret_id = "ditto-${var.environment}-stripe-secret-key"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret" "stripe_webhook_secret" {
  secret_id = "ditto-${var.environment}-stripe-webhook-secret"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled]
}
