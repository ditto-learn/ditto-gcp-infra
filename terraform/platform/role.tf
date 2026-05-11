locals {
  service_accounts = {
    backend = "ditto-backend-${var.environment}"
  }

  service_secret_access_pairs = [
    {
      key          = "backend:stripe-secret-key"
      service_name = "backend"
      secret_id    = google_secret_manager_secret.stripe_secret_key.secret_id
    },
    {
      key          = "backend:stripe-webhook-secret"
      service_name = "backend"
      secret_id    = google_secret_manager_secret.stripe_webhook_secret.secret_id
    },
    {
      key          = "backend:sentry-dsn"
      service_name = "backend"
      secret_id    = google_secret_manager_secret.sentry_dsn.secret_id
    },
    {
      key          = "backend:posthog-project-token"
      service_name = "backend"
      secret_id    = google_secret_manager_secret.posthog_project_token.secret_id
    },
    {
      key          = "backend:resend-api-key"
      service_name = "backend"
      secret_id    = google_secret_manager_secret.resend_api_key.secret_id
    },
    {
      key          = "backend:resend-webhook-secret"
      service_name = "backend"
      secret_id    = google_secret_manager_secret.resend_webhook_secret.secret_id
    },
    {
      key          = "backend:ai-action-signing-secret"
      service_name = "backend"
      secret_id    = google_secret_manager_secret.ai_action_signing_secret.secret_id
    },
    {
      key          = "backend:upstash-host"
      service_name = "backend"
      secret_id    = google_secret_manager_secret.upstash_host.secret_id
    },
    {
      key          = "backend:upstash-password"
      service_name = "backend"
      secret_id    = google_secret_manager_secret.upstash_password.secret_id
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
    if key == "backend"
  }

  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${each.value.email}"
}

resource "google_project_iam_member" "cloudsql_instance_user" {
  for_each = {
    for key, value in google_service_account.runtime :
    key => value
    if key == "backend"
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
