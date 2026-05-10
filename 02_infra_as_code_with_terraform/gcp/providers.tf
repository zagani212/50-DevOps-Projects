provider "google" {
  project     = "my-project-id"
  region      = "us-central1"
}

terraform {
  backend "gcs" {
    bucket  = "terraform_state_bucket_abdelhak"
    prefix  = "terraform/state"
  }
}
