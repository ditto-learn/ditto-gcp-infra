data "terraform_remote_state" "platform" {
  backend = "gcs"

  config = {
    bucket = var.platform_state_bucket
    prefix = var.platform_state_prefix
  }
}

data "terraform_remote_state" "database" {
  backend = "gcs"

  config = {
    bucket = var.database_state_bucket
    prefix = var.database_state_prefix
  }
}
