resource "google_artifact_registry_repository" "my_repository" {
  project       = data.google_project.default.project_id
  location      = "us-east1"
  repository_id = var.registry_name
  description   = "Docker repository for application images"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}
