terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0" # Use a modern version for 2026
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "terraform_state_bucket_abdelhak"
    prefix = "terraform/state"
  }
}
