data "google_project" "current" {
  project_id = var.project_id
}

resource "random_id" "speech_cdn_signed_url_key" {
  byte_length = 16

  keepers = {
    environment = var.environment
    key_name    = var.speech_cdn_signed_url_key_name
  }
}

locals {
  speech_cdn_signed_url_key = replace(replace(random_id.speech_cdn_signed_url_key.b64_std, "+", "-"), "/", "_")
}

resource "google_storage_bucket" "speech_assets" {
  project                     = var.project_id
  name                        = "${var.project_id}-${var.environment}-speech-assets"
  location                    = var.speech_assets_bucket_location
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  labels                      = local.common_labels
}

resource "google_storage_bucket_iam_member" "backend_speech_object_admin" {
  bucket = google_storage_bucket.speech_assets.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${local.service_accounts.backend}"
}

resource "google_compute_backend_bucket" "speech_assets" {
  project     = var.project_id
  name        = "ditto-speech-assets-${var.environment}"
  bucket_name = google_storage_bucket.speech_assets.name
  enable_cdn  = true

  cdn_policy {
    cache_mode                   = "CACHE_ALL_STATIC"
    request_coalescing           = true
    signed_url_cache_max_age_sec = var.speech_cdn_signed_url_cache_max_age_seconds
    negative_caching             = true
    serve_while_stale            = 86400
    client_ttl                   = 3600
    max_ttl                      = 31536000
    default_ttl                  = 3600
  }
}

resource "google_compute_backend_bucket_signed_url_key" "speech_assets" {
  project        = var.project_id
  name           = var.speech_cdn_signed_url_key_name
  key_value      = local.speech_cdn_signed_url_key
  backend_bucket = google_compute_backend_bucket.speech_assets.name
}

resource "google_storage_bucket_iam_member" "cdn_fill_speech_object_viewer" {
  bucket = google_storage_bucket.speech_assets.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:service-${data.google_project.current.number}@cloud-cdn-fill.iam.gserviceaccount.com"

  depends_on = [google_compute_backend_bucket_signed_url_key.speech_assets]
}

resource "google_compute_global_address" "speech_assets" {
  project = var.project_id
  name    = "ditto-speech-assets-${var.environment}"
}

resource "google_compute_url_map" "speech_assets" {
  project         = var.project_id
  name            = "ditto-speech-assets-${var.environment}"
  default_service = google_compute_backend_bucket.speech_assets.id
}

resource "google_compute_managed_ssl_certificate" "speech_assets" {
  project = var.project_id
  name    = "ditto-speech-assets-${var.environment}"

  managed {
    domains = [var.speech_cdn_domain]
  }
}

resource "google_compute_target_https_proxy" "speech_assets" {
  project          = var.project_id
  name             = "ditto-speech-assets-${var.environment}"
  url_map          = google_compute_url_map.speech_assets.id
  ssl_certificates = [google_compute_managed_ssl_certificate.speech_assets.id]
}

resource "google_compute_global_forwarding_rule" "speech_assets_https" {
  project               = var.project_id
  name                  = "ditto-speech-assets-${var.environment}-https"
  ip_address            = google_compute_global_address.speech_assets.address
  port_range            = "443"
  target                = google_compute_target_https_proxy.speech_assets.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_url_map" "speech_assets_http_redirect" {
  project = var.project_id
  name    = "ditto-speech-assets-${var.environment}-http-redirect"

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_target_http_proxy" "speech_assets_http_redirect" {
  project = var.project_id
  name    = "ditto-speech-assets-${var.environment}-http-redirect"
  url_map = google_compute_url_map.speech_assets_http_redirect.id
}

resource "google_compute_global_forwarding_rule" "speech_assets_http" {
  project               = var.project_id
  name                  = "ditto-speech-assets-${var.environment}-http"
  ip_address            = google_compute_global_address.speech_assets.address
  port_range            = "80"
  target                = google_compute_target_http_proxy.speech_assets_http_redirect.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
