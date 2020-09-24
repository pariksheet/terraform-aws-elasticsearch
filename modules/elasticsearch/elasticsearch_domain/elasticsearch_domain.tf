variable "ENV" {}
variable "PREFIX" {}
variable "SUBNET_IDS" {}
variable "SECURITY_GROUPS" {}
variable "AWS_REGION" {}
variable "COGNITO_MAP" {}
variable "ES_INSTANCE" {}
variable "ES_VOLUME_GB" {}
variable "ES_ENCRYPTION" {}
variable "DEFAULT_TAGS" {}

data "aws_caller_identity" "current" {}


data "aws_iam_policy_document" "cognito_es_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
          "cognito-idp:DescribeUserPool",
          "cognito-idp:CreateUserPoolClient",
          "cognito-idp:DeleteUserPoolClient",
          "cognito-idp:DescribeUserPoolClient",
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:AdminUserGlobalSignOut",
          "cognito-idp:ListUserPoolClients",
          "cognito-identity:DescribeIdentityPool",
          "cognito-identity:UpdateIdentityPool",
          "cognito-identity:SetIdentityPoolRoles",
          "cognito-identity:GetIdentityPoolRoles"
    ]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "es_assume_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "es_access_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${lookup(var.COGNITO_MAP, "auth_arn")}"]
    }
    actions = ["es:*"]
    resources = ["arn:aws:es:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:domain/${lower(var.PREFIX)}-${lower(var.ENV)}-elastic-search/*"]
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_iam_policy" "cognito_es_policy" {
  name = "${var.PREFIX}-${var.ENV}-COGNITO-ACCESS-ES-POLICY"
  description = "${var.PREFIX}-${var.ENV}-COGNITO-ACCESS-ES-POLICY"
  policy = data.aws_iam_policy_document.cognito_es_policy.json

}


resource "aws_iam_role" "cognito_es_role" {
  name = "${var.PREFIX}-${var.ENV}-COGNITO-ACCESS-ES-ROLE"
  assume_role_policy = data.aws_iam_policy_document.es_assume_policy.json

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-COGNITO-ACCESS-ES-ROLE")
	)
}

resource "aws_iam_role_policy_attachment" "cognito_es_attach" {
  role       = aws_iam_role.cognito_es_role.name
  policy_arn = aws_iam_policy.cognito_es_policy.arn
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${lower(var.PREFIX)}-${lower(var.ENV)}-elastic-search"
  elasticsearch_version = "7.4"

  cluster_config {
    instance_type = var.ES_INSTANCE
  }
  ebs_options {
      ebs_enabled = true
      volume_type = "gp2"
      volume_size = var.ES_VOLUME_GB
  }

  vpc_options {
    subnet_ids = var.SUBNET_IDS
    security_group_ids = var.SECURITY_GROUPS
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = data.aws_iam_policy_document.es_access_policy.json


  cognito_options {
      enabled = true
      user_pool_id = lookup(var.COGNITO_MAP, "user_pool")
      identity_pool_id = lookup(var.COGNITO_MAP, "identity_pool")
      role_arn = aws_iam_role.cognito_es_role.arn
  }
  domain_endpoint_options {
      enforce_https = true
      tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  encrypt_at_rest {
      enabled = var.ES_ENCRYPTION
  }
  snapshot_options {
    automated_snapshot_start_hour = 23
  }

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${lower(var.PREFIX)}-${lower(var.ENV)}-elastic-search")
	)

  depends_on = [aws_iam_service_linked_role.es, aws_iam_role_policy_attachment.cognito_es_attach]
}

output "es_domain" {
  description = "elasticsearch domain"
  value       =  aws_elasticsearch_domain.es
}