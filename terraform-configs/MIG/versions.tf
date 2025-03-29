terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
  required_version = "~> 1.0"
}

provider "google" {
  region = "us-east1"
}
