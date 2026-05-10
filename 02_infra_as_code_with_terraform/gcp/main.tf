module "networking" {
  source = "./networking"
  environment = var.environment
  region = var.region
}