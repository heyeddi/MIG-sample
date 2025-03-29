resource "google_compute_network" "default" {
  project = data.google_project.default.project_id
  name                    = "app-mig-vpc"
  auto_create_subnetworks = false
}

# Create Subnet manually because we don't need it in all regions
resource "google_compute_subnetwork" "default" {
  project = data.google_project.default.project_id
  name          = "app-mig-vpc-subnet"
  ip_cidr_range = "10.2.0.0/28"  # Choose an appropriate CIDR range
  region        = "us-east1"
  network       = google_compute_network.default.self_link
  private_ip_google_access = true
}

# Allow internal communication within the VPC
resource "google_compute_firewall" "allow_internal" {
  project = data.google_project.default.project_id
  name    = "app-mig-vpc-allow-internal"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["5432"] # Cloud SQL
  }

  source_ranges = [google_compute_subnetwork.default.ip_cidr_range]
}

# Add Internet Gateway
resource "google_compute_router" "router" {
 project = data.google_project.default.project_id
 name    = "app-mig-vpc-router"
 region  = "us-east1"
 network = google_compute_network.default.id
}

resource "google_compute_router_nat" "nat" {
 project = data.google_project.default.project_id
 name                               = "app-mig-vpc-nat"
 router                             = google_compute_router.router.name
 region                             = "us-east1"
 nat_ip_allocate_option             = "AUTO_ONLY"
 source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
