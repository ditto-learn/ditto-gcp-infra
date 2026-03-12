provider "google" {
  project = var.gcp_project_id
  region  = "europe-west2"
}

provider "supabase" {
  access_token = var.supabase_access_token
}
