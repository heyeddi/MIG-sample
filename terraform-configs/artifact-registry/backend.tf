terraform {
  backend "gcs" {
    bucket = "sample-state-bucket-3457890"
    prefix = "artifact-registry"
  }
}
