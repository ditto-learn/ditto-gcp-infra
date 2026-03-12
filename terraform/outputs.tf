output "environment" {
  value = var.environment
}

output "supabase_project_ref" {
  value = module.supabase.project_ref
}

output "supabase_project_url" {
  value = module.supabase.project_url
}

output "nat_allowlist_cidr" {
  value = module.network.nat_ip_cidr
}

output "cloud_run_urls" {
  value = module.gcp_runtime.cloud_run_urls
}

output "content_bucket_url" {
  value = module.gcp_runtime.content_bucket_url
}

output "gcp_project_number" {
  value = data.google_project.current.number
}

output "nextjs_invoker_service_account_email" {
  value = google_service_account.nextjs_invoker.email
}

output "vercel_wif_pool_id" {
  value = google_iam_workload_identity_pool.vercel.workload_identity_pool_id
}

output "vercel_wif_provider_id" {
  value = google_iam_workload_identity_pool_provider.vercel.workload_identity_pool_provider_id
}

output "vercel_wif_provider_name" {
  value = google_iam_workload_identity_pool_provider.vercel.name
}
