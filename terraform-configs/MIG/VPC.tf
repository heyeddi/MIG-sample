resource "google_compute_network" "default" {
  project                 = data.google_project.default.project_id
  name                    = "app-mig-vpc"
  auto_create_subnetworks = false
}

# Create Subnet manually because we don't need it in all regions
resource "google_compute_subnetwork" "default" {
  project                  = data.google_project.default.project_id
  name                     = "app-mig-vpc-subnet"
  ip_cidr_range            = "10.2.0.0/28"
  region                   = "us-east1"
  network                  = google_compute_network.default.id
  private_ip_google_access = true
}

# Allow internal communication within the VPC
resource "google_compute_firewall" "allow_internal" {
  project = data.google_project.default.project_id
  name    = "app-mig-vpc-allow-internal"
  network = google_compute_network.default.name

  # Allow SSH
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # no need to allow CLoudSQL, using the Connector
  allow {
    protocol = "tcp"
    ports    = ["5000"] # MIG instances
  }
  #source_ranges = ["0.0.0.0/0"] # for testing
  source_ranges = [google_compute_subnetwork.default.ip_cidr_range]
}

# Allocate IP range for private services (MIG, CloudSQL)
resource "google_compute_global_address" "private_ip_alloc" {
  project       = data.google_project.default.project_id
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.default.id
}

# Allow connections within the VPC
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.default.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# Add Internet Gateway
resource "google_compute_router" "router" {
  project = data.google_project.default.project_id
  name    = "app-mig-vpc-router"
  region  = "us-east1"
  network = google_compute_network.default.id
}

resource "google_compute_router_nat" "nat" {
  project                            = data.google_project.default.project_id
  name                               = "app-mig-vpc-nat"
  router                             = google_compute_router.router.name
  region                             = "us-east1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
