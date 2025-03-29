resource "google_service_account" "default" {
  project = data.google_project.default.project_id
  account_id   = "mig-sa"
  display_name = "MIG Service Account"
}

resource "google_project_iam_member" "sql_user_login" {
  project = data.google_project.default.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = google_service_account.default.member
}
