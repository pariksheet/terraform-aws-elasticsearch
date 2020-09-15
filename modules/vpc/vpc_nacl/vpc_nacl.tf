variable "ENV" {}
variable "PREFIX" {}
variable "VPC_ID" {}
variable "SUBNET" {}
variable "SUBNET_MAP" {}
variable "DEFAULT_TAGS" {}

resource "aws_network_acl" "nginx_pub_0" {
  vpc_id = var.VPC_ID
  subnet_ids = lookup(var.SUBNET_MAP, "nginx")
  tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-PUB-0-NETWORK-ACL")
	)
}

resource "aws_network_acl_rule" "nginx_pub_0_ingress_100" {
  network_acl_id = aws_network_acl.nginx_pub_0.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "nginx_pub_0_ingress_200" {
  network_acl_id = aws_network_acl.nginx_pub_0.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.160/27"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "nginx_pub_0_ingress_300" {
  network_acl_id = aws_network_acl.nginx_pub_0.id
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 32768
  to_port        = 61000
}

resource "aws_network_acl_rule" "nginx_pub_0_ingress_400" {
  network_acl_id = aws_network_acl.nginx_pub_0.id
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "nginx_pub_0_egress_100" {
  network_acl_id = aws_network_acl.nginx_pub_0.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "nginx_pub_0_egress_200" {
  network_acl_id = aws_network_acl.nginx_pub_0.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.160/27"
  from_port      = 32768
  to_port        = 65535
}

resource "aws_network_acl_rule" "nginx_pub_0_egress_300" {
  network_acl_id = aws_network_acl.nginx_pub_0.id
  rule_number    = 300
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "nginx_pub_0_egress_400" {
  network_acl_id = aws_network_acl.nginx_pub_0.id
  rule_number    = 400
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl" "nat_pub_1" {
  vpc_id = var.VPC_ID
  subnet_ids = lookup(var.SUBNET_MAP, "nat")
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-PUB-1-NETWORK-ACL")
	)
}

resource "aws_network_acl" "etl_pri_0" {
  vpc_id = var.VPC_ID
  subnet_ids = lookup(var.SUBNET_MAP, "etl")
  tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-PRI-0-NETWORK-ACL")
	)
}

resource "aws_network_acl_rule" "etl_pri_0_ingress_100" {
  network_acl_id = aws_network_acl.etl_pri_0.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "etl_pri_0_egress_100" {
  network_acl_id = aws_network_acl.etl_pri_0.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl" "pe_pri_1" {
  vpc_id = var.VPC_ID
  subnet_ids = lookup(var.SUBNET_MAP, "pe")
  tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-PRI-1-NETWORK-ACL")
	)
}

resource "aws_network_acl_rule" "pe_pri_1_ingress_100" {
  network_acl_id = aws_network_acl.pe_pri_1.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "pe_pri_1_egress_100" {
  network_acl_id = aws_network_acl.pe_pri_1.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl" "es_int_0" {
  vpc_id = var.VPC_ID
  subnet_ids = lookup(var.SUBNET_MAP, "es")
  tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-INT-0-NETWORK-ACL")
	)
}

resource "aws_network_acl_rule" "es_int_0_ingress_100" {
  network_acl_id = aws_network_acl.es_int_0.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.128/27"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "es_int_0_ingress_200" {
  network_acl_id = aws_network_acl.es_int_0.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.160/27"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "es_int_0_ingress_300" {
  network_acl_id = aws_network_acl.es_int_0.id
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.64/26"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "es_int_0_egress_100" {
  network_acl_id = aws_network_acl.es_int_0.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.128/27"
  from_port      = 32768
  to_port        = 65535
}

resource "aws_network_acl_rule" "es_int_0_egress_200" {
  network_acl_id = aws_network_acl.es_int_0.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.160/27"
  from_port      = 32768
  to_port        = 65535
}

resource "aws_network_acl_rule" "es_int_0_egress_300" {
  network_acl_id = aws_network_acl.es_int_0.id
  rule_number    = 300
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.64/26"
  from_port      = 32768
  to_port        = 65535
}

resource "aws_network_acl" "docdb_int_1" {
  vpc_id = var.VPC_ID
  subnet_ids = lookup(var.SUBNET_MAP, "docdb")
  tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-INT-1-NETWORK-ACL")
	)
}

resource "aws_network_acl_rule" "docdb_int_1_ingress_100" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.160/27"
  from_port      = 27017
  to_port        = 27017
}

resource "aws_network_acl_rule" "docdb_int_1_ingress_200" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.0/26"
  from_port      = 27017
  to_port        = 27017
}

resource "aws_network_acl_rule" "docdb_int_1_ingress_300" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.64/26"
  from_port      = 27017
  to_port        = 27017
}

resource "aws_network_acl_rule" "docdb_int_1_ingress_400" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.1.0/27"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "docdb_int_1_ingress_500" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 500
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.1.32/27"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "docdb_int_1_ingress_600" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 600
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.1.64/27"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "docdb_int_1_egress_100" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.160/27"
  from_port      = 32768
  to_port        = 65535
}

resource "aws_network_acl_rule" "docdb_int_1_egress_200" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.0/26"
  from_port      = 32768
  to_port        = 65535
}

resource "aws_network_acl_rule" "docdb_int_1_egress_300" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 300
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.0.64/26"
  from_port      = 32768
  to_port        = 65535
}

resource "aws_network_acl_rule" "docdb_int_1_egress_400" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 400
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.1.0/27"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "docdb_int_1_egress_500" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 500
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.1.32/27"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "docdb_int_1_egress_600" {
  network_acl_id = aws_network_acl.docdb_int_1.id
  rule_number    = 600
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.${var.SUBNET}.1.64/27"
  from_port      = 0
  to_port        = 65535
}


