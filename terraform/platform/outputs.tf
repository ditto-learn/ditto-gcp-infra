output "artifact_registry_repository" {
  value = google_artifact_registry_repository.containers.id
}

output "service_account_emails" {
  value = {
    for key, value in google_service_account.runtime :
    key => value.email
  }
}

output "secret_ids" {
  value = {
    stripe_secret_key        = google_secret_manager_secret.stripe_secret_key.secret_id
    stripe_webhook_secret    = google_secret_manager_secret.stripe_webhook_secret.secret_id
    sentry_dsn               = google_secret_manager_secret.sentry_dsn.secret_id
    ai_action_signing_secret = google_secret_manager_secret.ai_action_signing_secret.secret_id
    upstash_host             = google_secret_manager_secret.upstash_host.secret_id
    upstash_password         = google_secret_manager_secret.upstash_password.secret_id
  }
}
