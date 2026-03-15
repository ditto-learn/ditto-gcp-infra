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

variable "db_instance_name" {
  type    = string
  default = "ditto-postgres"
}

variable "db_name" {
  type    = string
  default = "ditto"
}

variable "db_version" {
  type    = string
  default = "POSTGRES_16"
}

variable "db_tier" {
  type    = string
  default = "db-custom-1-3840"
}

variable "platform_state_bucket" {
  type = string
}

variable "platform_state_prefix" {
  type = string
}
