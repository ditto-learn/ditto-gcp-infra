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

  validation {
    condition     = can(regex("^[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.www_domain))
    error_message = "www_domain must be a valid hostname."
  }
}

variable "app_domain" {
  type = string

  validation {
    condition     = can(regex("^[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.app_domain))
    error_message = "app_domain must be a valid hostname."
  }
}

variable "api_domain" {
  type = string

  validation {
    condition     = can(regex("^[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.api_domain))
    error_message = "api_domain must be a valid hostname."
  }
}

variable "identity_platform_project_id" {
  type = string
}

variable "stripe_pro_price_id" {
  type = string
}

variable "stripe_checkout_success_url" {
  type = string

  validation {
    condition     = can(regex("^https?://", var.stripe_checkout_success_url))
    error_message = "stripe_checkout_success_url must be an absolute http or https URL."
  }
}

variable "stripe_checkout_cancel_url" {
  type = string

  validation {
    condition     = can(regex("^https?://", var.stripe_checkout_cancel_url))
    error_message = "stripe_checkout_cancel_url must be an absolute http or https URL."
  }
}

variable "stripe_portal_return_url" {
  type = string

  validation {
    condition     = can(regex("^https?://", var.stripe_portal_return_url))
    error_message = "stripe_portal_return_url must be an absolute http or https URL."
  }
}

variable "container_images" {
  type = object({
    web_app = string
    backend = string
  })

  validation {
    condition = alltrue([
      for image in values(var.container_images) :
      length(trimspace(image)) > 0 && can(regex(".+/.+:.+", image))
    ])
    error_message = "container_images values must be non-empty container image references with a tag."
  }
}

variable "cors_origins" {
  type = object({
    ai = string
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

variable "secret_version" {
  type = string

  validation {
    condition     = can(regex("^[1-9][0-9]*$", var.secret_version))
    error_message = "secret_version must be a positive numeric secret version."
  }
}
