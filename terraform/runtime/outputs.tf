output "backend_url" {
  description = "Auto-generated *.run.app URL for the backend Cloud Run service."
  value       = module.backend.uri
}
