provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  state_buckets = toset([
    "ditto-tf-state-local",
    "ditto-tf-state-test",
    "ditto-tf-state-prod",
  ])
}

resource "google_storage_bucket" "tf_state" {
  for_each = local.state_buckets

  name          = each.key
  project       = var.project_id
  location      = var.region
  force_destroy = false

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true

  lifecycle {
    prevent_destroy = true
  }
}
