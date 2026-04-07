output "vpc_id" {
  value = module.network.vpc_id
}

output "subnet_id" {
  value = module.network.subnet_id
}

output "nat_ip_address" {
  value = module.network.nat_ip_address
}

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
    google_genai_api_key  = google_secret_manager_secret.google_genai_api_key.secret_id
    stripe_secret_key     = google_secret_manager_secret.stripe_secret_key.secret_id
    stripe_webhook_secret = google_secret_manager_secret.stripe_webhook_secret.secret_id
    sentry_dsn            = google_secret_manager_secret.sentry_dsn.secret_id
  }
}
