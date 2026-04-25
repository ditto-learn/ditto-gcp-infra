resource "google_secret_manager_secret" "stripe_secret_key" {
  secret_id = "ditto-${var.environment}-stripe-secret-key"
  project   = var.project_id

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret" "stripe_webhook_secret" {
  secret_id = "ditto-${var.environment}-stripe-webhook-secret"
  project   = var.project_id

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret" "sentry_dsn" {
  secret_id = "ditto-${var.environment}-sentry-dsn"
  project   = var.project_id

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret" "ai_action_signing_secret" {
  secret_id = "ditto-${var.environment}-ai-action-signing-secret"
  project   = var.project_id

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.enabled]
}

# Upstash Redis credentials for the rate limiter. Hostname is per-database
# (e.g. `eu1-loving-newt-12345.upstash.io`); password is the access token.
# Port is hardcoded in Terraform (Upstash uses 6379 for all standard TLS
# databases) — no secret needed. Rotation = regenerate the token on Upstash,
# `gcloud secrets versions add`, bump Cloud Run revision.
resource "google_secret_manager_secret" "upstash_host" {
  secret_id = "ditto-${var.environment}-upstash-host"
  project   = var.project_id

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret" "upstash_password" {
  secret_id = "ditto-${var.environment}-upstash-password"
  project   = var.project_id

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.enabled]
}
