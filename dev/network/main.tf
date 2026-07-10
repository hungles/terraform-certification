module "vpc-dev" {
  source = "../../modules/vpc"

  enable_nat_gateway  = var.enable_nat_gateway
  enable_vpn_gateway  = var.enable_vpn_gateway
  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  tags                = var.tags
  private_subnet_tags = var.private_subnet_tags
  public_subnet_tags  = var.public_subnet_tags
}