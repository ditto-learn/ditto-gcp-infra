output "cloud_sql_connection_name" {
  value = google_sql_database_instance.main.connection_name
}

output "db_name" {
  value = google_sql_database.main.name
}
