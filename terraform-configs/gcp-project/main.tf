locals {
  project_id   = var.project_id
  project_name = var.project_name
  # Enable APIs
  services = []
  billing_account = var.billing_account_id
}

# Create Project
resource "google_project" "project" {
  name            = local.project_name
  project_id      = local.project_id
  billing_account = local.billing_account
}

# Enable APIs on project
resource "google_project_service" "services" {
  for_each = toset(local.services)

  project = google_project.project.project_id
  service = each.value

  disable_dependent_services = true
}
