locals {
  spec = {
    spec = {
      containers = [{
        image = "us-east1-docker.pkg.dev/eddi-sample-project/eddi-registry/simple-python-app:latest"
      }]
      restartPolicy = "Always"
    }
  }

  spec_as_yaml = yamlencode(local.spec)
}

data "google_artifact_registry_docker_image" "default" {
  project       = data.google_project.default.project_id
  location      = "us-east1"
  repository_id = var.registry_name
  image_name    = var.image_name
}

# Google Compute Instance Template with Docker
resource "google_compute_instance_template" "default" {
  project      = data.google_project.default.project_id
  name_prefix  = "docker-template-"
  machine_type = "e2-micro" # Smallest machine
  tags         = ["http-server"]

  disk {
    source_image = "cos-cloud/cos-stable"
    auto_delete  = true
    boot         = true
    disk_size_gb = 10
  }

  network_interface {
    # Put it in the VPC
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
  }

  # From https://github.com/terraform-google-modules/terraform-google-container-vm/blob/main/main.tf
  metadata = {
    gce-container-declaration = local.spec_as_yaml
  }

  service_account {
    email  = google_service_account.default.email
    scopes = ["cloud-platform", "https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Managed Instance Group
resource "google_compute_region_instance_group_manager" "default" {
  project            = data.google_project.default.project_id
  name               = "docker-mig"
  base_instance_name = "docker-instance"
  region             = "us-east1"
  target_size        = 1

  version {
    instance_template = google_compute_instance_template.default.id
  }

  named_port {
    name = "http"
    port = 5000
  }
}

# Autoscaler
resource "google_compute_region_autoscaler" "default" {
  project = data.google_project.default.project_id
  name    = "docker-autoscaler"
  region  = "us-east1"
  target  = google_compute_region_instance_group_manager.default.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }
}

resource "google_compute_health_check" "default" {
  project             = data.google_project.default.project_id
  name                = "docker-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {
    port         = 5000
    request_path = "/health"
  }
}
