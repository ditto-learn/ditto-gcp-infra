terraform {
  required_providers {
    supabase = {
      source = "supabase/supabase"
    }
  }
}

resource "supabase_project" "this" {
  organization_id   = var.organization_id
  name              = var.project_name
  database_password = var.database_password
  region            = var.region
  instance_size     = var.instance_size
}

data "supabase_apikeys" "this" {
  project_ref = supabase_project.this.id
}

resource "supabase_settings" "this" {
  project_ref = supabase_project.this.id

  api = jsonencode({
    db_schema            = "public,storage,graphql_public"
    db_extra_search_path = "public,extensions"
    max_rows             = var.max_rows
  })

  auth = jsonencode(merge(
    { site_url = var.site_url },
    length(var.additional_redirect_urls) > 0
    ? { uri_allow_list = join(",", var.additional_redirect_urls) }
    : {}
  ))

  network = jsonencode({
    restrictions = concat([var.nat_allowlist_cidr], var.additional_allowed_cidrs)
  })
}
