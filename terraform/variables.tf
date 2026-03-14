variable "project_id" {
  type = string
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
}

variable "db_user" {
  type    = string
  default = "ditto_app"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "identity_platform_project_id" {
  type = string
}

variable "google_genai_api_key" {
  type      = string
  sensitive = true
}

variable "container_images" {
  type = object({
    public_site  = string
    web_app      = string
    access       = string
    learning     = string
    intelligence = string
    ai           = string
  })
}

variable "cors_origins" {
  type = object({
    public_site  = list(string)
    web_app      = list(string)
    access       = list(string)
    learning     = list(string)
    intelligence = list(string)
    ai           = list(string)
  })
}
