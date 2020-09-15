variable "ENV" {}
variable "PREFIX" {}
variable "AWS_REGION" {}
variable "SUBNET" {}
variable "AZ" {}
variable "INSTANCE_KEY_PATH" {}
variable "DEFAULT_TAGS" {}

locals {
  instance_pub_key = "${var.INSTANCE_KEY_PATH}.pub"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.${var.SUBNET}.0.0/22"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-VPC")
	)
}

resource "aws_key_pair" "instance_key" {
  key_name   = basename(var.INSTANCE_KEY_PATH)
  public_key = file(local.instance_pub_key)

  tags = merge(
    var.DEFAULT_TAGS,
    map("Name", "${var.PREFIX}-${var.ENV}-INSTANCE-KEY")
  )
}

resource "aws_subnet" "nginx_pub_0" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.${var.SUBNET}.0.128/27"
  availability_zone       = var.AZ[1]

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-PUB-0-SN")
	)
}


resource "aws_subnet" "es_int_0" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.${var.SUBNET}.0.192/27"
  availability_zone       = var.AZ[1]

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-INT-0-SN")
	)
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-IGW")
	)
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-PUB-RT")
	)
}

resource "aws_route_table" "int_rt" {
  vpc_id = aws_vpc.main.id

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-INT-RT")
	)
}

resource "aws_route_table_association" "nginx_pub_0" {
  subnet_id      = aws_subnet.nginx_pub_0.id
  route_table_id = aws_route_table.pub_rt.id
}


resource "aws_route_table_association" "es_int_0" {
  subnet_id      = aws_subnet.es_int_0.id
  route_table_id = aws_route_table.int_rt.id
}


output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}


output "es_subnet" {
  description = "Subnet reserved for elastic search"
  value       = aws_subnet.es_int_0.id
}

output "nginx_subnet" {
  description = "Subnet reserved for elastic search"
  value       = aws_subnet.nginx_pub_0.id
}

output "route_tables" {
  description = "route tables"
  value       = [aws_route_table.pub_rt.id, aws_route_table.int_rt.id]
}

output "instance_key" {
  description = "key pair for aws instances"
  value       = aws_key_pair.instance_key.key_name
}

output "subnet_map" {
  description = "subnets created in this vpc"
  value       = { "nginx" = [aws_subnet.nginx_pub_0.id]
                  "es" = [aws_subnet.es_int_0.id]
                }
}

