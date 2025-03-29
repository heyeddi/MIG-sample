# Configure secret
# To simplfy, I created the secret version manually on the cloud console
# import with `terraform import google_secret_manager_secret.db_password_secret projects/{PROJECT_ID}/secrets/db-password`
resource "google_secret_manager_secret" "db_password_secret" {
  project = data.google_project.default.id
  secret_id = "db-password"
  replication {
    auto {}
  }
  lifecycle {
    ignore_changes = [ project ] # prevent replaccement after importing
  }
}

# Retrieve the latest version of the secret
# This was created manually on the console for simplicity
data "google_secret_manager_secret_version_access" "db_password_latest" {
  secret = google_secret_manager_secret.db_password_secret.id
}

