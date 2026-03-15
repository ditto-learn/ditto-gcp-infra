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

variable "artifact_registry_repository_id" {
  type    = string
  default = "ditto-containers"
}

variable "identity_platform_project_id" {
  type = string
}
