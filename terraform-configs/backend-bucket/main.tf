locals {
  project_id = var.project_id
}

data "google_project" "project" {
  project_id = local.project_id
}

resource "google_storage_bucket" "terraform_state" {
  project       = data.google_project.project.project_id
  name          = "sample-state-bucket-3457890" # hardcoded for simplicity
  location      = "US"
  force_destroy = true
  versioning {
    enabled = true
  }
}
