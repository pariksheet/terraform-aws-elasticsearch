variable "ENV" {}
variable "PREFIX" {}
variable "INSTANCE_TYPE" {}
variable "INSTANCE_VOLUME" {}
variable "SUBNET_ID" {}
variable "SECURITY_GROUPS" {}
variable "AWS_REGION" {}
variable "PEM_KEY" {}
variable "ES_ENDPOINT" {}
variable "COGNITO_DOMAIN" {}
variable "DEFAULT_TAGS" {}


data "aws_ami" "amazon_linux" {
most_recent = true
owners = ["amazon"]
  filter {
      name   = "name"
      values = ["amzn-ami-hvm-2018.03.0.20190826-x86_64-gp2"]
  }
  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

data "aws_iam_policy" "ssm_ec2_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "template_file" "userdata" {
  template = file("../commons/configure_nginx.sh")
  vars = map(
        "es_endpoint", var.ES_ENDPOINT,
        "cognito_domain", var.COGNITO_DOMAIN
      )
}

resource "aws_iam_role" "nginx_role" {
  name = "${var.PREFIX}-${var.ENV}-NGINX-INSTANCE-ROLE"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ssm.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-NGINX-INSTANCE-ROLE")
	)
}

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "${var.PREFIX}-${var.ENV}-NGINX-INSTANCE-PROFILE"
  role = aws_iam_role.nginx_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_ec2_role" {
  role       = aws_iam_role.nginx_role.name
  policy_arn = data.aws_iam_policy.ssm_ec2_role.arn
}

resource "aws_instance" "nginx" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.INSTANCE_TYPE
  iam_instance_profile = aws_iam_instance_profile.nginx_profile.id
  key_name = var.PEM_KEY
  vpc_security_group_ids = var.SECURITY_GROUPS
  subnet_id = var.SUBNET_ID

  root_block_device {
    volume_type = "gp2"
    volume_size = var.INSTANCE_VOLUME
  }

  user_data = data.template_file.userdata.rendered

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-NGINX-EC2")
	)

  lifecycle { create_before_destroy = true }
}

resource "aws_eip" "nginx" {
  vpc = true

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-NGINX-EIP")
	)

}

resource "aws_eip_association" "ngix_eip" {
  instance_id   = aws_instance.nginx.id
  allocation_id = aws_eip.nginx.id
}

output "nginx_instance" {
  description = "nginx instance"
  value       =  aws_instance.nginx
}

output "nginx_ip" {
  description = "nginx elastic ip"
  value       =  aws_eip.nginx
}