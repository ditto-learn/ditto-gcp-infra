variable "environment" {
  type = string

  validation {
    condition     = contains(["test", "prod"], var.environment)
    error_message = "environment must be one of: test, prod."
  }
}

variable "gcp_project_id" {
  type = string
}

variable "supabase_access_token" {
  type      = string
  sensitive = true
}

variable "supabase_organization_id" {
  type = string
}

variable "supabase_project_name" {
  type = string
}

variable "supabase_database_password" {
  type      = string
  sensitive = true
}

variable "supabase_instance_size" {
  type    = string
  default = "micro"
}

variable "supabase_region" {
  type    = string
  default = "eu-west-2"

  validation {
    condition     = var.supabase_region == "eu-west-2"
    error_message = "London-only policy enforced: Supabase region must be eu-west-2."
  }
}

variable "site_url" {
  type = string
}

variable "additional_redirect_urls" {
  type    = list(string)
  default = []
}

variable "supabase_max_rows" {
  type    = number
  default = 1000
}

variable "supabase_additional_allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "subnet_cidr" {
  type    = string
  default = "10.8.0.0/26"
}

variable "ai_image" {
  type = string
}

variable "learning_image" {
  type = string
}

variable "question_image" {
  type = string
}

variable "nextjs_invoker_service_account_id" {
  type    = string
  default = "web-backend"
}

variable "vercel_oidc" {
  type = object({
    workload_identity_pool_id          = string
    workload_identity_pool_provider_id = string
    issuer_mode                        = string
    team_slug                          = string
    allowed_audiences                  = list(string)
    allowed_subjects                   = list(string)
  })

  validation {
    condition     = contains(["global", "team"], var.vercel_oidc.issuer_mode)
    error_message = "vercel_oidc.issuer_mode must be either \"global\" or \"team\"."
  }

  validation {
    condition     = var.vercel_oidc.issuer_mode == "global" || length(trimspace(var.vercel_oidc.team_slug)) > 0
    error_message = "vercel_oidc.team_slug is required when vercel_oidc.issuer_mode is \"team\"."
  }

  validation {
    condition     = length(var.vercel_oidc.allowed_audiences) > 0
    error_message = "vercel_oidc.allowed_audiences must include at least one audience."
  }

  validation {
    condition     = length(var.vercel_oidc.allowed_subjects) > 0
    error_message = "vercel_oidc.allowed_subjects must include at least one Vercel OIDC subject."
  }
}

variable "google_genai_api_key" {
  type      = string
  sensitive = true
}

variable "supabase_jwt_secret" {
  type      = string
  sensitive = true
}

variable "cors_origins" {
  type = object({
    ai       = list(string)
    learning = list(string)
    question = list(string)
  })
  default = { ai = [], learning = [], question = [] }
}

variable "content_bucket_name_override" {
  type    = string
  default = null
}

variable "cloud_run_custom_audiences" {
  type = object({
    ai       = list(string)
    learning = list(string)
    question = list(string)
  })
  default = {
    ai       = []
    learning = []
    question = []
  }
}
