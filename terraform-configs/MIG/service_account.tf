resource "google_service_account" "default" {
  project      = data.google_project.default.project_id
  account_id   = "mig-sa"
  display_name = "MIG Service Account"
}

resource "google_project_iam_member" "sql_user_login" {
  project = data.google_project.default.project_id
  role    = "roles/cloudsql.client"
  member  = google_service_account.default.member
}

resource "google_project_iam_member" "secret_accessor" {
  project = data.google_project.default.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = google_service_account.default.member
}

resource "google_project_iam_member" "artifact_reader" {
  project = data.google_project.default.project_id
  role    = "roles/artifactregistry.reader"
  member  = google_service_account.default.member
}
