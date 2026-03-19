locals {
  apis = toset([
    "artifactregistry.googleapis.com",
    "certificatemanager.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ])
}

resource "google_project_service" "enabled" {
  for_each = local.apis

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}

module "network" {
  source      = "../modules/network"
  project_id  = var.project_id
  environment = var.environment
  region      = var.region

  depends_on = [google_project_service.enabled]
}

resource "google_artifact_registry_repository" "containers" {
  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_registry_repository_id
  format        = "DOCKER"

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.enabled]
}
