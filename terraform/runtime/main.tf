locals {
  platform = data.terraform_remote_state.platform.outputs
  database = data.terraform_remote_state.database.outputs

  service_accounts = local.platform.service_account_emails
  secret_ids       = local.platform.secret_ids
  db_socket        = "/cloudsql/${local.database.cloud_sql_connection_name}"

  common_labels = {
    environment = var.environment
    managed_by  = "terraform"
    component   = "runtime"
    project     = "ditto"
  }
}

# Vertex AI access for the backend runtime service account. genai.Client()
# authenticates via the Cloud Run service account when
# GOOGLE_GENAI_USE_VERTEXAI=true (set at startup by
# apply_google_runtime_settings). No API key is used — the GenAI API key
# secret was removed in this PR.
resource "google_project_iam_member" "backend_vertex_ai_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${local.service_accounts.backend}"
}

# ── Cloud Tasks queues ────────────────────────────────────────────────
# One queue today: writing evaluation. Each task is ~30s of Gemini work,
# so concurrency is low and backoff is generous. (The previous
# plan-claim-sync queue was deleted along with the `ditto_plan` Firebase
# custom claim — Stripe webhooks update the DB directly and `/me` reads
# the plan from there. Do not reintroduce a Firebase plan claim.)

module "writing_eval_queue" {
  source = "../modules/cloud_tasks_queue"

  project_id                = var.project_id
  region                    = var.region
  name                      = "writing-eval-${var.environment}"
  max_dispatches_per_second = 3
  max_concurrent_dispatches = 10
  max_attempts              = 8
  min_backoff               = "10s"
  max_backoff               = "600s"
}

module "email_send_queue" {
  source = "../modules/cloud_tasks_queue"

  project_id                = var.project_id
  region                    = var.region
  name                      = "email-send-${var.environment}"
  max_dispatches_per_second = 10
  max_concurrent_dispatches = 30
  max_attempts              = 8
  min_backoff               = "10s"
  max_backoff               = "600s"
}

# The backend SA enqueues tasks into the queue.
resource "google_project_iam_member" "backend_cloud_tasks_enqueuer" {
  project = var.project_id
  role    = "roles/cloudtasks.enqueuer"
  member  = "serviceAccount:${local.service_accounts.backend}"
}

# Cloud Tasks signs each delivery as the configured OIDC service account —
# here, the backend SA itself. To let the SA mint OIDC tokens for itself,
# it needs `roles/iam.serviceAccountTokenCreator` on its own SA.
resource "google_service_account_iam_member" "backend_sa_token_creator" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${local.service_accounts.backend}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${local.service_accounts.backend}"
}

# Cloud Scheduler signs sweeper POSTs as the backend service account, using
# the same internal-task OIDC verifier as Cloud Tasks deliveries.
resource "google_service_account_iam_member" "scheduler_backend_token_creator" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${local.service_accounts.backend}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-cloudscheduler.iam.gserviceaccount.com"
}

resource "google_cloud_scheduler_job" "writing_eval_sweep" {
  name        = "writing-eval-sweep-${var.environment}"
  description = "Re-enqueue stale writing evaluations."
  project     = var.project_id
  region      = var.region
  schedule    = "*/2 * * * *"
  time_zone   = "Etc/UTC"

  http_target {
    http_method = "POST"
    uri         = "${trim(var.cloud_tasks_service_base_url, "/")}/internal/tasks/writing-eval-sweep"
    headers = {
      "Content-Type" = "application/json"
    }
    body = base64encode(jsonencode({
      limit               = 50
      stale_after_seconds = 120
    }))

    oidc_token {
      service_account_email = local.service_accounts.backend
      audience              = "${trim(var.cloud_tasks_service_base_url, "/")}/internal/tasks/writing-eval-sweep"
    }
  }

  depends_on = [
    module.backend,
    google_service_account_iam_member.scheduler_backend_token_creator,
  ]
}

module "backend" {
  source = "../modules/cloud_run_service"

  project_id            = var.project_id
  name                  = "ditto-backend-${var.environment}"
  region                = var.region
  image                 = var.container_images.backend
  port                  = 8080
  service_account_email = local.service_accounts.backend
  invoker_member        = "allUsers"
  ingress               = "INGRESS_TRAFFIC_ALL"
  min_instances         = var.api_min_instances
  deletion_protection   = var.service_deletion_protection
  cloud_sql_instances   = [local.database.cloud_sql_connection_name]
  labels                = local.common_labels
  secret_version        = var.secret_version
  # No VPC attachment: every downstream (Cloud SQL via socket, Upstash /
  # Vertex / Firebase / Stripe via public internet) is reachable through the
  # default Cloud Run egress path. If a future service requires VPC-private
  # access, add `network_id` / `subnetwork_id` / `vpc_egress` back here.
  plain_env = {
    APP_ENV                           = var.environment
    DB_CONNECTION_URL                 = "postgresql://${replace(local.service_accounts.backend, "@", "%40")}@/${local.database.db_name}?host=${local.db_socket}"
    ASYNC_DB_CONNECTION_URL           = "postgresql+asyncpg://${replace(local.service_accounts.backend, "@", "%40")}@/${local.database.db_name}?host=${local.db_socket}"
    DATABASE__POOL_MIN_SIZE           = "2"
    DATABASE__POOL_MAX_SIZE           = "20"
    IDENTITY_PLATFORM_PROJECT_ID      = var.identity_platform_project_id
    IDENTITY_PLATFORM_USERNAME_DOMAIN = var.identity_platform_username_domain
    DITTO_ALLOWED_HOSTS               = var.api_allowed_hosts
    CORS_ALLOW_ORIGINS                = var.cors_origins.web
    WEB_APP_URL                       = var.web_app_url
    ADMIN_ALLOWED_EMAILS              = var.admin_allowed_emails
    POSTHOG_HOST                      = "https://eu.i.posthog.com"
    POSTHOG_ENABLED                   = "true"

    EMAIL__ENABLED      = "true"
    EMAIL__FROM_ADDRESS = "Nook <hello@nook.learning>"
    EMAIL__APP_BASE_URL = var.web_app_url

    STRIPE_FAMILY_PRO_PRICE_ID  = var.stripe_family_pro_price_id
    STRIPE_CHECKOUT_SUCCESS_URL = var.stripe_checkout_success_url
    STRIPE_CHECKOUT_CANCEL_URL  = var.stripe_checkout_cancel_url
    STRIPE_PORTAL_RETURN_URL    = var.stripe_portal_return_url

    # Vertex AI (IAM-authenticated via the runtime service account). No
    # API key secret is injected — `apply_google_runtime_settings` flips
    # `GOOGLE_GENAI_USE_VERTEXAI=true` at startup so `genai.Client()`
    # authenticates via ADC against the Cloud Run SA.
    AI_MODEL_PROVIDER     = "vertex_ai"
    AI_USE_VERTEX_AI      = "true"
    GOOGLE_CLOUD_PROJECT  = var.project_id
    GOOGLE_CLOUD_LOCATION = var.region
    # Upstash Redis backs the rate limiter. `REDIS__*` maps to
    # `settings.redis.*` via Pydantic `env_nested_delimiter="__"`. TLS is
    # always on for Upstash; `fail_open=false` means the app refuses to boot
    # if Upstash is unreachable — we'd rather see a boot crash than
    # silently fall back to per-process in-memory counters. Host + password
    # come from Secret Manager (see `secret_env`). Port is not sensitive;
    # Upstash uses 6379 for all standard TLS databases.
    REDIS__ENABLED   = "true"
    REDIS__SSL       = "true"
    REDIS__PORT      = "6379"
    REDIS__FAIL_OPEN = "false"

    # Cloud Tasks dispatcher. `enabled=true` keeps writing evaluation and
    # transactional email on durable HTTPS task delivery, so the work
    # survives API instance recycle.
    # `service_base_url` is the backend's own public URL — Cloud Tasks
    # POSTs back to `/internal/tasks/*` on the same service with an
    # OIDC token.
    CLOUD_TASKS__ENABLED               = "true"
    CLOUD_TASKS__PROJECT_ID            = var.project_id
    CLOUD_TASKS__LOCATION              = var.region
    CLOUD_TASKS__WRITING_EVAL_QUEUE    = module.writing_eval_queue.name
    CLOUD_TASKS__EMAIL_SEND_QUEUE      = module.email_send_queue.name
    CLOUD_TASKS__SERVICE_BASE_URL      = var.cloud_tasks_service_base_url
    CLOUD_TASKS__SERVICE_ACCOUNT_EMAIL = local.service_accounts.backend

    # Gemini-TTS speech cache: synthesize once in Cloud Run, store immutable
    # MP3s in a private GCS bucket, and return Cloud CDN signed URLs to the
    # browser. Local dev keeps `cache_backend=local` from application-local.
    SPEECH__ENGINE                 = "google"
    SPEECH__CACHE_BACKEND          = "gcs"
    SPEECH__GCS_BUCKET             = google_storage_bucket.speech_assets.name
    SPEECH__GCS_PREFIX             = "speech"
    SPEECH__PUBLIC_BASE_URL        = "https://${var.speech_cdn_domain}"
    SPEECH__SIGNED_URL_KEY_NAME    = var.speech_cdn_signed_url_key_name
    SPEECH__SIGNED_URL_KEY         = local.speech_cdn_signed_url_key
    SPEECH__SIGNED_URL_TTL_SECONDS = tostring(var.speech_cdn_signed_url_ttl_seconds)
  }
  secret_env = {
    STRIPE_SECRET_KEY            = local.secret_ids.stripe_secret_key
    STRIPE_WEBHOOK_SECRET        = local.secret_ids.stripe_webhook_secret
    AI_ACTION_SIGNING_SECRET     = local.secret_ids.ai_action_signing_secret
    SENTRY_DSN                   = local.secret_ids.sentry_dsn
    POSTHOG_PROJECT_TOKEN        = local.secret_ids.posthog_project_token
    EMAIL__RESEND_API_KEY        = local.secret_ids.resend_api_key
    EMAIL__RESEND_WEBHOOK_SECRET = local.secret_ids.resend_webhook_secret
    REDIS__HOST                  = local.secret_ids.upstash_host
    REDIS__PASSWORD              = local.secret_ids.upstash_password
  }

  depends_on = [
    module.writing_eval_queue,
    module.email_send_queue,
    google_storage_bucket_iam_member.backend_speech_object_admin,
    google_storage_bucket_iam_member.cdn_fill_speech_object_viewer,
    google_compute_global_forwarding_rule.speech_assets_https,
  ]
}
