terraform {
  backend "gcs" {
    bucket = "sample-state-bucket-3457890"
    prefix = "MIG-sample"
  }
}
