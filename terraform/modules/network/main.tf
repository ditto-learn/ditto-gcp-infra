resource "google_compute_network" "this" {
  name                    = "serverless-${var.environment}"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name                      = "serverless-${var.environment}"
  project                   = var.project_id
  region                    = var.region
  network                   = google_compute_network.this.id
  ip_cidr_range             = var.subnet_cidr
  private_ip_google_access = true
}

resource "google_compute_router" "nat" {
  name    = "nat-router-${var.environment}"
  project = var.project_id
  region  = var.region
  network = google_compute_network.this.id
}

resource "google_compute_address" "nat" {
  name    = "nat-ip-${var.environment}"
  project = var.project_id
  region  = var.region
}

resource "google_compute_router_nat" "this" {
  name                               = "nat-${var.environment}"
  project                            = var.project_id
  region                             = var.region
  router                             = google_compute_router.nat.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
