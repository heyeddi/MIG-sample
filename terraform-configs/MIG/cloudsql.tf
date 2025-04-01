resource "google_sql_database_instance" "default" {
  project          = data.google_project.default.project_id
  name             = var.database_name
  database_version = "POSTGRES_15"
  region           = "us-east1"
  settings {
    tier = "db-f1-micro" # Cheapest available instance type
    ip_configuration {
      ipv4_enabled    = false # this stays within the VPC
      private_network = google_compute_network.default.id
    }
    # Cost optimization settings
    disk_autoresize = false
    disk_size       = 10
    disk_type       = "PD_HDD"
    backup_configuration {
      enabled = false
    }
  }

  # Set `deletion_protection` to true to prevent accidental deletion.
  deletion_protection = false # Not needed for this sample
  depends_on          = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "database" {
  project  = data.google_project.default.project_id
  name     = var.database_name
  instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "user" {
  project     = data.google_project.default.project_id
  name        = "mig-app-user"
  instance    = google_sql_database_instance.default.name
  password_wo = var.db_password
}

# Secret to store the database password
resource "google_secret_manager_secret" "db_password" {
  project   = data.google_project.default.project_id
  secret_id = "mig-db-password"

  replication {
    auto {}
  }
}

# Store the password in the secret
resource "google_secret_manager_secret_version" "db_password" {
  secret         = google_secret_manager_secret.db_password.id
  secret_data_wo = var.db_password
}
