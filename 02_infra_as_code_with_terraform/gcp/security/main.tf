resource "google_compute_firewall" "default" {
  name    = "compute-firewall"
  network = var.vpc_network_id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "433"]
  }

  target_tags = ["vm"]

  source_ranges = ["0.0.0.0/0"]
}