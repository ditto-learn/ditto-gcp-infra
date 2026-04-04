output "load_balancer_ip_address" {
  value = google_compute_global_address.edge.address
}

output "service_urls" {
  value = {
    web_app = module.web_app.uri
    backend = module.backend.uri
  }
}
