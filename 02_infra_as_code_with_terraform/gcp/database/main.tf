resource "google_sql_database_instance" "instance" {
  name                = "my-database-instance"
  region              = var.region
  database_version    = "POSTGRES_18"
  deletion_protection = false
  edition = "ENTERPRISE"

  settings {
    tier = "db-f1-micro"
    # ip_configuration {
    #   ipv4_enabled    = false # Disables Public IP
    #   private_network = var.vpc_network_id
    # }
  }
}