output "load_balancer_ip_address" {
  value = google_compute_global_address.edge.address
}

output "service_urls" {
  value = {
    web_app      = module.web_app.uri
    access       = module.access_service.uri
    billing      = module.billing_service.uri
    learning     = module.learning_service.uri
    intelligence = module.intelligence_service.uri
    ai           = module.ai_service.uri
  }
}
