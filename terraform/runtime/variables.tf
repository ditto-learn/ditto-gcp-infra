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

variable "identity_platform_project_id" {
  type = string
}

variable "identity_platform_username_domain" {
  type        = string
  description = "Domain used for generated managed-learner usernames."

  validation {
    condition     = length(trimspace(var.identity_platform_username_domain)) > 0
    error_message = "identity_platform_username_domain must be non-empty."
  }
}

variable "stripe_family_pro_price_id" {
  description = "Stripe price ID for the PRO_FAMILY plan. Backend reads via STRIPE_FAMILY_PRO_PRICE_ID."
  type        = string
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
    web = string
  })
}

variable "api_allowed_hosts" {
  type        = string
  description = "Comma-separated hostnames accepted by TrustedHostMiddleware, e.g. api.dittolearn.com."

  validation {
    condition     = length(trimspace(var.api_allowed_hosts)) > 0 && !strcontains(var.api_allowed_hosts, "*")
    error_message = "api_allowed_hosts must be explicit and must not contain wildcards."
  }
}

variable "web_app_url" {
  type        = string
  description = "Public web app origin used in links and Stripe redirects."

  validation {
    condition     = can(regex("^https://[^/]+$", var.web_app_url))
    error_message = "web_app_url must be an https origin with no trailing slash."
  }
}

variable "admin_allowed_emails" {
  type        = string
  description = "Comma-separated Firebase emails allowed through backend admin routes."

  validation {
    condition     = length(trimspace(var.admin_allowed_emails)) > 0
    error_message = "admin_allowed_emails must include at least one operator email."
  }
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

variable "secret_version" {
  type = string

  validation {
    condition     = can(regex("^[1-9][0-9]*$", var.secret_version))
    error_message = "secret_version must be a positive numeric secret version."
  }
}

variable "api_min_instances" {
  type    = number
  default = 0
}

variable "service_deletion_protection" {
  type    = bool
  default = false
}

variable "alert_email" {
  type        = string
  description = "Email address for monitoring alert notifications."
}

variable "monthly_budget_amount" {
  type        = number
  default     = 50
  description = "Monthly budget alert threshold in USD."
}

variable "cloud_tasks_service_base_url" {
  type        = string
  description = "The backend's own public HTTPS URL. Cloud Tasks posts back to this base + /internal/tasks/* with an OIDC token. No trailing slash. Typically the Cloud Run URL (or a custom domain mapped to it)."

  validation {
    condition     = can(regex("^https://[^/]+$", var.cloud_tasks_service_base_url))
    error_message = "cloud_tasks_service_base_url must be an https URL with no trailing slash."
  }
}

variable "billing_account" {
  type        = string
  description = "Billing account ID in the form XXXXXX-XXXXXX-XXXXXX."

  validation {
    condition     = can(regex("^[A-Z0-9]{6}-[A-Z0-9]{6}-[A-Z0-9]{6}$", var.billing_account))
    error_message = "billing_account must be in the form XXXXXX-XXXXXX-XXXXXX."
  }
}
