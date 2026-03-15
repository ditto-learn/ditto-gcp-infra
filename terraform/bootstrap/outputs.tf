output "state_bucket_names" {
  value = { for k, v in google_storage_bucket.tf_state : k => v.name }
}
