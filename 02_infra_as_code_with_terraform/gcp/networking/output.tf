output "public_subnetwork_name_az1" {
  value = google_compute_subnetwork.public_subnetwork_az1.name
}

output "public_subnetwork_name_az2" {
  value = google_compute_subnetwork.public_subnetwork_az2.name
}

output "private_subnetwork_name_az1" {
  value = google_compute_subnetwork.private_subnetwork_az1.name
}

output "private_subnetwork_name_az2" {
  value = google_compute_subnetwork.private_subnetwork_az2.name
}

output "vpc_network_id" {
  value = google_compute_network.vpc_network.id
}