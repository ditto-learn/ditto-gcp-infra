variable "project_id" {
  type = string
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["test", "prod"], var.environment)
    error_message = "environment must be test or prod."
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
  type        = string
  default     = "db-f1-micro"
  description = "Smallest shared-core tier. Bump to db-g1-small (~$25/mo) when you see OOMs in Cloud Logging, then db-custom-1-3840 once paying users arrive."
}

variable "db_backup_enabled" {
  type    = bool
  default = true
}

variable "db_pitr_enabled" {
  type    = bool
  default = true
}

variable "db_transaction_log_retention_days" {
  type    = number
  default = 3
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "platform_state_bucket" {
  type = string
}

variable "platform_state_prefix" {
  type = string
}
