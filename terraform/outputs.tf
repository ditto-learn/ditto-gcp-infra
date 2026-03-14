output "load_balancer_ip_address" {
  value = google_compute_global_address.edge.address
}

output "cloud_sql_connection_name" {
  value = google_sql_database_instance.main.connection_name
}

output "artifact_registry_repository" {
  value = google_artifact_registry_repository.containers.id
}
