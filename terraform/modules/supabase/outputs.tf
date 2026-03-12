output "project_ref" {
  value = supabase_project.this.id
}

output "project_url" {
  value = "https://${supabase_project.this.id}.supabase.co"
}

output "database_host" {
  value = "db.${supabase_project.this.id}.supabase.co"
}

output "anon_key" {
  value     = data.supabase_apikeys.this.anon_key
  sensitive = true
}

output "service_role_key" {
  value     = data.supabase_apikeys.this.service_role_key
  sensitive = true
}
