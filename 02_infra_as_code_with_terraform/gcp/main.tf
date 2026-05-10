module "networking" {
  source      = "./networking"
  environment = var.environment
  region      = var.region
}

module "compute" {
  source = "./compute"

  public_subnetwork_name_az1  = module.networking.public_subnetwork_name_az1
  public_subnetwork_name_az2  = module.networking.public_subnetwork_name_az2
  private_subnetwork_name_az1 = module.networking.private_subnetwork_name_az1
  private_subnetwork_name_az2 = module.networking.private_subnetwork_name_az2

  zone_az1 = "us-central1-a"
  zone_az2 = "us-central1-b"
}

module "database" {
  source         = "./database"
  vpc_network_id = module.networking.vpc_network_id
  region         = var.region
}