locals {
  default_tags = map("Environment", var.ENV, "Project", var.PREFIX)
}

module "vpc" {
  source            = "../modules/vpc"
  ENV               = var.ENV
  AWS_REGION        = var.AWS_REGION
  PREFIX            = var.PREFIX
  SUBNET            = var.SUBNET
  INSTANCE_KEY_PATH = var.INSTANCE_KEY_PATH
  DEFAULT_TAGS      = local.default_tags
}


module "es" {
  source                = "../modules/elasticsearch"
  ENV                   = var.ENV
  PREFIX                = var.PREFIX
  AWS_REGION            = var.AWS_REGION  
  VPC_ID                = module.vpc.vpc_id
  SUBNET_IDS            = lookup(module.vpc.subnet_map, "es")
  SECURITY_GROUPS       = [lookup(module.vpc.security_group_map, "es")]
  ES_INSTANCE           = var.ES_INSTANCE
  ES_VOLUME_GB          = var.ES_VOLUME_GB
  ES_ENCRYPTION         = var.ES_ENCRYPTION
  NGINX_SUBNET_ID       = element(lookup(module.vpc.subnet_map, "nginx"), 0)
  NGINX_INSTANCE        = var.NGINX_INSTANCE
  NGINX_VOLUME_GB       = 10
  NGINX_SECURITY_GROUPS = [lookup(module.vpc.security_group_map, "nginx")]
  NGINX_KEY             = module.vpc.instance_key
  DEFAULT_TAGS          = local.default_tags
}

resource "null_resource" "wait_for_nginx" {
    provisioner "local-exec" {
    when = create
    command = "sleep 200"
    }
    depends_on = [module.es]
}

output "nginx" {
  description = "nginx instance info"
  value       =  {
    "private_ip" = module.es.nginx_instance.private_ip
    "public_ip" = module.es.nginx_public_ip
    "ssh_cmd" = "ssh -i ${var.INSTANCE_KEY_PATH} ec2-user@${module.es.nginx_instance.id}"
  }
}

output "elasticsearch" {
  description = "elasticsearch info"
  value       =  module.es.elasticsearch
}

output "tags" {
  description = "Tags assigned to each resource"
  value       = local.default_tags
}