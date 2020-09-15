locals {
  azs = ["${var.AWS_REGION}a", "${var.AWS_REGION}b", "${var.AWS_REGION}c"]
}

module "vpc_base" {
  source     = "./vpc_base"
  ENV        = var.ENV
  AWS_REGION = var.AWS_REGION
  PREFIX = var.PREFIX
  SUBNET = var.SUBNET
  AZ = local.azs
  INSTANCE_KEY_PATH = var.INSTANCE_KEY_PATH
  DEFAULT_TAGS = var.DEFAULT_TAGS
}

module "vpc_sg" {
  source     = "./vpc_sg"
  ENV        = var.ENV
  PREFIX = var.PREFIX
  VPC_ID = module.vpc_base.vpc_id
  DEFAULT_TAGS = var.DEFAULT_TAGS
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc_base.vpc_id
}

output "security_group_map" {
  description = "security groups created in this vpc"
  value       = module.vpc_sg.security_group_map
}

output "subnet_map" {
  description = "subnets created in this vpc"
  value       = module.vpc_base.subnet_map
}

output "route_tables" {
  description = "route tables"
  value       = module.vpc_base.route_tables
}

output "instance_key" {
  description = "keypair for aws instances"
  value       = module.vpc_base.instance_key
}