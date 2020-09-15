variable "ENV" {}
variable "PREFIX" {}
variable "VPC_ID" {}
variable "DEFAULT_TAGS" {}


resource "aws_security_group" "nginx_sg" {
  name        = "${var.PREFIX}-${var.ENV}-NGINX-SG"
  description = "Nginx security group"
  vpc_id      = var.VPC_ID
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-NGINX-SG")
	)
}

resource "aws_security_group" "es_sg" {
  name        = "${var.PREFIX}-${var.ENV}-ES-SG"
  description = "Elasticsearch security group"
  vpc_id      = var.VPC_ID
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-ES-SG")
	)
}

resource "aws_security_group_rule" "nginx_sg_internet_https_rule" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  security_group_id = aws_security_group.nginx_sg.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "es_sg_nginx_https_rule" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  security_group_id = aws_security_group.es_sg.id
  source_security_group_id  = aws_security_group.nginx_sg.id
}

output "security_group_map" {
  description = "security groups created in this vpc"
  value       = { "nginx" = aws_security_group.nginx_sg.id
                  "es"    = aws_security_group.es_sg.id
                }
}