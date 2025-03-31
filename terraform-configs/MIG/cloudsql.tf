resource "google_sql_database_instance" "default" {
  project = data.google_project.default.project_id
  name             = var.database_name
  database_version = "POSTGRES_15"
  region = "us-east1"
  settings {
    tier = "db-f1-micro"  # Cheapest available instance type
    ip_configuration {
      ipv4_enabled    = true # this stays within the VPC
    }
  }
  # Set `deletion_protection` to true to prevent accidental deletion.
  deletion_protection  = true
}

resource "google_sql_database" "database" {
  project = data.google_project.default.project_id
  name     = var.database_name
  instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "user" {
  project = data.google_project.default.project_id
  name     = replace(google_service_account.default.email, ".gserviceaccount.com", "")
  instance = google_sql_database_instance.default.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}
