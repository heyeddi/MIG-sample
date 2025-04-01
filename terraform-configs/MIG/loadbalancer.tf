# get an IP agreess for the lb
resource "google_compute_global_address" "lb_ip" {
  project = data.google_project.default.project_id
  name    = "app-lb-ip"
}


# Create a backend service that points to your MIG
resource "google_compute_backend_service" "default" {
  project     = data.google_project.default.project_id
  name        = "app-backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  health_checks = [google_compute_health_check.default.id]

  backend {
    group = google_compute_region_instance_group_manager.default.instance_group
    balancing_mode = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# URL map to route requests to your backend
resource "google_compute_url_map" "default" {
  project     = data.google_project.default.project_id
  name        = "app-url-map"
  default_service = google_compute_backend_service.default.id
}

# HTTP proxy to handle requests
resource "google_compute_target_http_proxy" "default" {
  project = data.google_project.default.project_id
  name    = "app-http-proxy"
  url_map = google_compute_url_map.default.id
}

# Global forwarding rule for HTTP should use port 80
resource "google_compute_global_forwarding_rule" "http" {
  project    = data.google_project.default.project_id
  name       = "app-http-forwarding-rule"
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"  # This should be 80 for HTTP
  ip_address = google_compute_global_address.lb_ip.address
}

# Firewall rule to allow traffic from the load balancer to your instances
resource "google_compute_firewall" "lb_to_instances" {
  project = data.google_project.default.project_id
  name    = "allow-lb-to-instances"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] # GCP load balancer IP ranges
  target_tags   = ["http-server"]
}
