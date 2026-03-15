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

variable "identity_platform_project_id" {
  type = string
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
  type = object({
    ai = list(string)
  })
}

variable "platform_state_bucket" {
  type = string
}

variable "platform_state_prefix" {
  type = string
}

variable "database_state_bucket" {
  type = string
}

variable "database_state_prefix" {
  type = string
}

variable "manage_dns_records" {
  type    = bool
  default = false
}

variable "dns_managed_zone" {
  type    = string
  default = null
}

variable "dns_project_id" {
  type    = string
  default = null
}
