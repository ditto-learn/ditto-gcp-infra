locals {
  service_accounts = {
    ai       = "ai-eng-${var.environment}"
    learning = "learn-eng-${var.environment}"
    question = "ques-eng-${var.environment}"
  }

  secret_keys = toset(nonsensitive(keys(var.secret_values)))

  secret_ids = {
    for key in local.secret_keys :
    key => "${lower(replace(key, "_", "-"))}-${var.environment}"
  }

  service_secret_access = {
    ai = toset([
      "SUPABASE_URL",
      "SUPABASE_SERVICE_ROLE_KEY",
      "SUPABASE_JWT_SECRET",
      "SESSION_SERVICE_URI",
      "GOOGLE_GENAI_API_KEY"
    ])
    learning = toset([])
    question = toset([])
  }

  secret_access_pairs = flatten([
    for sa_key, secret_keys in local.service_secret_access : [
      for secret_key in secret_keys : {
        sa_key     = sa_key
        secret_key = secret_key
      }
    ]
  ])
}

resource "google_artifact_registry_repository" "containers" {
  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_repository_id
  format        = "DOCKER"
}

resource "google_storage_bucket" "edu_content" {
  name                        = var.content_bucket_name
  location                    = upper(var.region)
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = false
}

resource "google_service_account" "runtime" {
  for_each = local.service_accounts

  project      = var.project_id
  account_id   = each.value
  display_name = "${upper(each.key)} runtime (${var.environment})"
}

resource "google_secret_manager_secret" "runtime" {
  for_each = local.secret_keys

  project   = var.project_id
  secret_id = local.secret_ids[each.key]

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "runtime" {
  for_each = local.secret_keys

  secret      = google_secret_manager_secret.runtime[each.key].id
  secret_data = var.secret_values[each.key]
}

resource "google_secret_manager_secret_iam_member" "runtime_access" {
  for_each = {
    for pair in local.secret_access_pairs :
    "${pair.secret_key}:${pair.sa_key}" => {
      secret_key = pair.secret_key
      sa_key     = pair.sa_key
    }
  }

  project   = var.project_id
  secret_id = google_secret_manager_secret.runtime[each.value.secret_key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.runtime[each.value.sa_key].email}"
}

resource "google_secret_manager_secret_iam_member" "nextjs_worker_secret_access" {
  for_each = toset([
    "SUPABASE_URL",
    "SUPABASE_SERVICE_ROLE_KEY",
  ])

  project   = var.project_id
  secret_id = google_secret_manager_secret.runtime[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = var.nextjs_invoker_member
}

module "ai_engine" {
  source = "../cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-ai-engine-${var.environment}"
  region                = var.region
  image                 = var.container_images.ai
  port                  = 8000
  service_account_email = google_service_account.runtime["ai"].email
  invoker_member        = var.nextjs_invoker_member
  # Intentionally ALL ingress: caller is external (Vercel), while IAM still
  # enforces authenticated invocation via roles/run.invoker only.
  ingress       = "INGRESS_TRAFFIC_ALL"
  network_id    = var.network_id
  subnetwork_id = var.subnetwork_id

  plain_env = {
    APP_ENV                   = var.environment
    GOOGLE_CLOUD_PROJECT      = var.project_id
    GOOGLE_CLOUD_LOCATION     = var.region
    GOOGLE_GENAI_USE_VERTEXAI = "TRUE"
    CORS_ORIGINS              = var.cors_origins.ai
  }
  custom_audiences = var.cloud_run_custom_audiences.ai

  secret_env = {
    SUPABASE_URL              = google_secret_manager_secret.runtime["SUPABASE_URL"].secret_id
    SUPABASE_SERVICE_ROLE_KEY = google_secret_manager_secret.runtime["SUPABASE_SERVICE_ROLE_KEY"].secret_id
    SUPABASE_JWT_SECRET       = google_secret_manager_secret.runtime["SUPABASE_JWT_SECRET"].secret_id
    SESSION_SERVICE_URI       = google_secret_manager_secret.runtime["SESSION_SERVICE_URI"].secret_id
    GOOGLE_GENAI_API_KEY      = google_secret_manager_secret.runtime["GOOGLE_GENAI_API_KEY"].secret_id
  }

  depends_on = [
    google_secret_manager_secret_version.runtime,
    google_secret_manager_secret_iam_member.nextjs_worker_secret_access,
  ]
}

module "learning_engine" {
  source = "../cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-learning-engine-${var.environment}"
  region                = var.region
  image                 = var.container_images.learning
  port                  = 8080
  service_account_email = google_service_account.runtime["learning"].email
  invoker_member        = var.nextjs_invoker_member
  # Intentionally ALL ingress: caller is external (Vercel), while IAM still
  # enforces authenticated invocation via roles/run.invoker only.
  ingress       = "INGRESS_TRAFFIC_ALL"
  network_id    = var.network_id
  subnetwork_id = var.subnetwork_id

  plain_env = {
    APP_ENV                      = var.environment
    LEARNING_ENGINE_CORS_ORIGINS = var.cors_origins.learning
  }
  custom_audiences = var.cloud_run_custom_audiences.learning

  depends_on = [
    google_secret_manager_secret_version.runtime,
    google_secret_manager_secret_iam_member.nextjs_worker_secret_access,
  ]
}

module "question_engine" {
  source = "../cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-question-engine-${var.environment}"
  region                = var.region
  image                 = var.container_images.question
  port                  = 8080
  service_account_email = google_service_account.runtime["question"].email
  invoker_member        = var.nextjs_invoker_member
  # Intentionally ALL ingress: caller is external (Vercel), while IAM still
  # enforces authenticated invocation via roles/run.invoker only.
  ingress       = "INGRESS_TRAFFIC_ALL"
  network_id    = var.network_id
  subnetwork_id = var.subnetwork_id

  plain_env = {
    APP_ENV                      = var.environment
    QUESTION_ENGINE_CORS_ORIGINS = var.cors_origins.question
  }
  custom_audiences = var.cloud_run_custom_audiences.question

  depends_on = [google_secret_manager_secret_version.runtime]
}
