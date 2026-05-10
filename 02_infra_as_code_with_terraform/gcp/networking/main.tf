resource "google_compute_network" "vpc_network" {
  name = "${var.environment}-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_subnetwork_az1" {
  name          = "${var.environment}-private-subnetwork-az1"
  ip_cidr_range = "10.1.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "private_subnetwork_az2" {
  name          = "${var.environment}-private-subnetwork-az2"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "public_subnetwork_az1" {
  name          = "${var.environment}-public-subnetwork-az1"
  ip_cidr_range = "10.3.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "public_subnetwork_az2" {
  name          = "${var.environment}-public-subnetwork-az2"
  ip_cidr_range = "10.4.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}