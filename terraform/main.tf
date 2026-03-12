locals {
  gcp_region = "europe-west2"

  content_bucket_name = coalesce(
    var.content_bucket_name_override,
    "ditto-edu-content-${var.gcp_project_id}-${var.environment}"
  )

  vercel_oidc_issuer_uri = var.vercel_oidc.issuer_mode == "team" ? "https://oidc.vercel.com/${var.vercel_oidc.team_slug}" : "https://oidc.vercel.com"
  nextjs_invoker_member  = "serviceAccount:${google_service_account.nextjs_invoker.email}"
}

# Project-level API enablement — project-scoped concern, lives at root
resource "google_project_service" "apis" {
  for_each = toset([
    "aiplatform.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "sts.googleapis.com",
  ])
  project            = var.gcp_project_id
  service            = each.key
  disable_on_destroy = false
}

data "google_project" "current" {
  project_id = var.gcp_project_id
}

resource "google_service_account" "nextjs_invoker" {
  project      = var.gcp_project_id
  account_id   = "${var.nextjs_invoker_service_account_id}-${var.environment}"
  display_name = "Next.js invoker (${var.environment})"

  depends_on = [google_project_service.apis]
}

resource "google_iam_workload_identity_pool" "vercel" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = var.vercel_oidc.workload_identity_pool_id
  display_name              = "Vercel OIDC (${var.environment})"
  description               = "Workload Identity Pool for Vercel Next.js (${var.environment})."

  depends_on = [google_project_service.apis]
}

resource "google_iam_workload_identity_pool_provider" "vercel" {
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.vercel.workload_identity_pool_id
  workload_identity_pool_provider_id = var.vercel_oidc.workload_identity_pool_provider_id
  display_name                       = "Vercel OIDC provider (${var.environment})"
  description                        = "Federates Vercel OIDC tokens into GCP short-lived credentials."

  oidc {
    issuer_uri        = local.vercel_oidc_issuer_uri
    allowed_audiences = var.vercel_oidc.allowed_audiences
  }

  attribute_mapping = {
    "google.subject" = "assertion.sub"
    "attribute.sub"  = "assertion.sub"
  }

  # Restrict trusted identities to explicit Vercel project/environment subjects.
  attribute_condition = join(" || ", [
    for subject in var.vercel_oidc.allowed_subjects :
    "assertion.sub==\"${subject}\""
  ])

  depends_on = [google_iam_workload_identity_pool.vercel]
}

resource "google_service_account_iam_member" "nextjs_invoker_wif_user" {
  for_each = toset(var.vercel_oidc.allowed_subjects)

  service_account_id = google_service_account.nextjs_invoker.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.vercel.workload_identity_pool_id}/subject/${each.value}"
}

resource "google_service_account_iam_member" "nextjs_invoker_token_creator" {
  service_account_id = google_service_account.nextjs_invoker.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.nextjs_invoker.email}"
}

module "network" {
  source      = "./modules/network"
  project_id  = var.gcp_project_id
  environment = var.environment
  region      = local.gcp_region
  subnet_cidr = var.subnet_cidr
  depends_on  = [google_project_service.apis]
}

module "supabase" {
  source = "./modules/supabase"

  organization_id          = var.supabase_organization_id
  project_name             = var.supabase_project_name
  database_password        = var.supabase_database_password
  region                   = var.supabase_region
  instance_size            = var.supabase_instance_size
  site_url                 = var.site_url
  additional_redirect_urls = var.additional_redirect_urls
  max_rows                 = var.supabase_max_rows
  nat_allowlist_cidr       = module.network.nat_ip_cidr
  additional_allowed_cidrs = var.supabase_additional_allowed_cidrs
}

module "gcp_runtime" {
  source = "./modules/gcp_runtime"

  project_id          = var.gcp_project_id
  environment         = var.environment
  region              = local.gcp_region
  content_bucket_name = local.content_bucket_name
  network_id          = module.network.vpc_id
  subnetwork_id       = module.network.subnet_id

  container_images = {
    ai       = var.ai_image
    learning = var.learning_image
    question = var.question_image
  }
  nextjs_invoker_member = local.nextjs_invoker_member

  secret_values = {
    SUPABASE_URL              = module.supabase.project_url
    SUPABASE_SERVICE_ROLE_KEY = module.supabase.service_role_key
    SUPABASE_JWT_SECRET       = var.supabase_jwt_secret
    SESSION_SERVICE_URI       = "postgresql+asyncpg://postgres:${var.supabase_database_password}@${module.supabase.database_host}:5432/postgres"
    GOOGLE_GENAI_API_KEY      = var.google_genai_api_key
  }

  cors_origins = {
    ai       = join(",", var.cors_origins.ai)
    learning = join(",", var.cors_origins.learning)
    question = join(",", var.cors_origins.question)
  }

  cloud_run_custom_audiences = var.cloud_run_custom_audiences

  depends_on = [
    google_project_service.apis,
    google_iam_workload_identity_pool_provider.vercel,
    google_service_account_iam_member.nextjs_invoker_wif_user,
    google_service_account_iam_member.nextjs_invoker_token_creator,
  ]
}
