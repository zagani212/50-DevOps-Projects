resource "google_sql_database_instance" "instance" {
  name                = "my-database-instance"
  region              = var.region
  deletion_protection = false
  database_version    = "POSTGRES_18"

  settings {
    tier = "db-f1-micro"
    edition = "ENTERPRISE"
    # ip_configuration {
    #   ipv4_enabled    = false # Disables Public IP
    #   private_network = var.vpc_network_id
    # }
  }
}