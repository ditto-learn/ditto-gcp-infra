output "backend_url" {
  description = "Auto-generated *.run.app URL for the backend Cloud Run service."
  value       = module.backend.uri
}

output "speech_assets_bucket" {
  description = "Private GCS bucket used for cached Gemini-TTS MP3 assets."
  value       = google_storage_bucket.speech_assets.name
}

output "speech_cdn_url" {
  description = "HTTPS base URL returned by the backend for speech assets."
  value       = "https://${var.speech_cdn_domain}"
}

output "speech_cdn_ip_address" {
  description = "Global load-balancer IP address. Point the speech CDN hostname at this address."
  value       = google_compute_global_address.speech_assets.address
}
