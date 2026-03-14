resource "google_secret_manager_secret" "db_connection_url" {
  secret_id = "ditto-${var.environment}-db-connection-url"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret_version" "db_connection_url" {
  secret      = google_secret_manager_secret.db_connection_url.id
  secret_data = local.db_connection_url
}

resource "google_secret_manager_secret" "session_service_uri" {
  secret_id = "ditto-${var.environment}-session-service-uri"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret_version" "session_service_uri" {
  secret      = google_secret_manager_secret.session_service_uri.id
  secret_data = local.session_service_uri
}

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

resource "google_secret_manager_secret" "local_service_token" {
  secret_id = "ditto-${var.environment}-local-service-token"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret_version" "local_service_token" {
  secret      = google_secret_manager_secret.local_service_token.id
  secret_data = var.local_service_token
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
