output "artifact_repository" {
  value = google_artifact_registry_repository.containers.name
}

output "content_bucket_url" {
  value = google_storage_bucket.edu_content.url
}

output "service_account_emails" {
  value = {
    ai       = google_service_account.runtime["ai"].email
    learning = google_service_account.runtime["learning"].email
    question = google_service_account.runtime["question"].email
  }
}

output "cloud_run_urls" {
  value = {
    ai       = module.ai_engine.uri
    learning = module.learning_engine.uri
    question = module.question_engine.uri
  }
}

output "secret_ids" {
  value = {
    for key, secret in google_secret_manager_secret.runtime :
    key => secret.secret_id
  }
}
