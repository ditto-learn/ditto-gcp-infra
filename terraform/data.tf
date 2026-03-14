data "google_client_config" "current" {}

data "google_project" "current" {
  project_id = var.project_id
}
