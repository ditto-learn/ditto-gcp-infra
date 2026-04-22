output "name" {
  value       = google_cloud_tasks_queue.this.name
  description = "Flat queue name (e.g. \"writing-eval\")."
}

output "id" {
  value       = google_cloud_tasks_queue.this.id
  description = "Full Cloud Tasks queue id (projects/<proj>/locations/<region>/queues/<name>)."
}
