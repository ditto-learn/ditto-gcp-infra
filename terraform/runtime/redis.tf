resource "google_redis_instance" "rate_limit" {
  project        = var.project_id
  name           = "ditto-redis-${var.environment}"
  region         = var.region
  tier           = var.redis_tier
  memory_size_gb = 1

  authorized_network = data.terraform_remote_state.platform.outputs.vpc_id

  redis_version = "REDIS_7_2"

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    component   = "runtime"
    project     = "ditto"
  }
}
