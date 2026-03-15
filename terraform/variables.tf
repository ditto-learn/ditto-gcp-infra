variable "project_id" {
  type = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["local", "test", "prod"], var.environment)
    error_message = "environment must be local, test, or prod."
  }
}

variable "region" {
  type    = string
  default = "europe-west2"

  validation {
    condition     = length(var.region) > 0
    error_message = "region must not be empty."
  }
}

variable "www_domain" {
  type = string
}

variable "app_domain" {
  type = string
}

variable "api_domain" {
  type = string
}

variable "artifact_registry_repository_id" {
  type    = string
  default = "ditto-containers"
}

variable "db_instance_name" {
  type    = string
  default = "ditto-postgres"
}

variable "db_name" {
  type    = string
  default = "ditto"

  validation {
    condition     = length(var.db_name) > 0
    error_message = "db_name must not be empty."
  }
}

variable "identity_platform_project_id" {
  type = string
}

variable "google_genai_api_key" {
  type      = string
  sensitive = true
}

variable "stripe_secret_key" {
  type      = string
  sensitive = true
}

variable "stripe_webhook_secret" {
  type      = string
  sensitive = true
}

variable "stripe_pro_price_id" {
  type = string
}

variable "stripe_checkout_success_url" {
  type = string
}

variable "stripe_checkout_cancel_url" {
  type = string
}

variable "stripe_portal_return_url" {
  type = string
}

variable "container_images" {
  type = object({
    public_site  = string
    web_app      = string
    access       = string
    learning     = string
    intelligence = string
    ai           = string
    billing      = string
  })
}

variable "cors_origins" {
  description = "CORS allowed origins per service"
  type = object({
    ai = list(string)
  })
}

variable "db_version" {
  description = "Cloud SQL Postgres version"
  type        = string
  default     = "POSTGRES_16"
}

variable "db_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-custom-1-3840"
}
