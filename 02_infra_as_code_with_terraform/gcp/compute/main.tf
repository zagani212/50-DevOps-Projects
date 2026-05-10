resource "google_service_account" "default" {
  account_id   = "my-custom-sa"
  display_name = "Custom SA for VM Instance"
}

resource "google_compute_instance" "vm_public_az1" {
  name         = "vm-${var.public_subnetwork_name_az1}"
  machine_type = "e2-medium"
  zone         = var.zone_az1

  tags = ["vm"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20260504"
    }
  }

  network_interface {
    subnetwork = var.public_subnetwork_name_az1
    access_config {}
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "vm_public_az2" {
  name         = "vm-${var.public_subnetwork_name_az2}"
  machine_type = "e2-medium"
  zone         = var.zone_az2

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20260504"
    }
  }

  network_interface {
    subnetwork = var.public_subnetwork_name_az2
    access_config {}
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "vm_private_az1" {
  name         = "vm-${var.private_subnetwork_name_az1}"
  machine_type = "e2-medium"
  zone         = var.zone_az1

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20260504"
    }
  }

  network_interface {
    subnetwork = var.private_subnetwork_name_az1
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "vm_private_az2" {
  name         = "vm-${var.private_subnetwork_name_az2}"
  machine_type = "e2-medium"
  zone         = var.zone_az2

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20260504"
    }
  }

  network_interface {
    subnetwork = var.private_subnetwork_name_az2
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}