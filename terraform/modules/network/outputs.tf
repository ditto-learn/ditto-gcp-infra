output "vpc_id" {
  value = google_compute_network.this.id
}

output "subnet_id" {
  value = google_compute_subnetwork.this.id
}

output "nat_ip_cidr" {
  value = "${google_compute_address.nat.address}/32"
}

output "nat_ip_address" {
  value = google_compute_address.nat.address
}
