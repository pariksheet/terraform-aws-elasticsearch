variable "ENV" {}
variable "PREFIX" {}
variable "AWS_REGION" {}
variable "DEFAULT_TAGS" {}

resource "random_integer" "num" {
  min     = 10000
  max     = 50000
}

resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.PREFIX}_${var.ENV}_USER_POOL"
  admin_create_user_config {
      allow_admin_create_user_only = true
  }
  auto_verified_attributes = ["email"]
  mfa_configuration = "OFF"
  username_attributes = ["email"]
  user_pool_add_ons {
      advanced_security_mode = "OFF"
  }
  password_policy {
      minimum_length = 8
      require_lowercase = true
      require_numbers = true
      require_symbols = true
      require_uppercase = true
      temporary_password_validity_days = 7
  }

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}_${var.ENV}_USER_POOL")
	)  
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${lower(var.PREFIX)}-${lower(var.ENV)}-user-pool-client-${random_integer.num.result}"

  user_pool_id = aws_cognito_user_pool.user_pool.id
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = "${lower(var.PREFIX)}-${lower(var.ENV)}-user-pool-domain-${random_integer.num.result}"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "${var.PREFIX}_${var.ENV}_IDENTITY_POOL"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id       = aws_cognito_user_pool_client.client.id
    provider_name   = aws_cognito_user_pool.user_pool.endpoint
  }

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}_${var.ENV}_IDENTITY_POOL")
	)  

  lifecycle {ignore_changes = [cognito_identity_providers]}
}

resource "aws_iam_role" "authenticated" {
  name = "${var.PREFIX}-${var.ENV}-COGNITO-AUTH-ROLE"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Effect": "Allow",
    "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
        "StringEquals": {
        "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.identity_pool.id}"
        },
        "ForAnyValue:StringLike": {
        "cognito-identity.amazonaws.com:amr": "authenticated"
        }
    }
    }
]
}
EOF

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-COGNITO-AUTH-ROLE")
	)
}

resource "aws_iam_role_policy" "authenticated" {
  name = "authenticated_policy"
  role = aws_iam_role.authenticated.id

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
  "Effect": "Allow",
  "Action": [
      "mobileanalytics:PutEvents",
      "cognito-sync:*"
  ],
  "Resource": [
      "*"
  ]
  }
]
}
EOF
}

resource "aws_iam_role" "unauthenticated" {
  name = "${var.PREFIX}-${var.ENV}-COGNITO-UNAUTH-ROLE"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
  "Effect": "Allow",
  "Principal": {
      "Federated": "cognito-identity.amazonaws.com"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
      "StringEquals": {
      "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.identity_pool.id}"
      },
      "ForAnyValue:StringLike": {
      "cognito-identity.amazonaws.com:amr": "unauthenticated"
      }
  }
  }
]
}
EOF

	tags = merge(
			var.DEFAULT_TAGS,
			map("Name", "${var.PREFIX}-${var.ENV}-COGNITO-UNAUTH-ROLE")
	)
}

resource "aws_iam_role_policy" "unauthenticated" {
  name = "authenticated_policy"
  role = aws_iam_role.authenticated.id

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
  "Effect": "Allow",
  "Action": [
      "mobileanalytics:PutEvents",
      "cognito-sync:*"
  ],
  "Resource": [
      "*"
  ]
  }
]
}
EOF
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id
  roles = {
    "authenticated" = aws_iam_role.authenticated.arn
    "unauthenticated" = aws_iam_role.unauthenticated.arn
  }
}

output "cognito_map" {
  description = "congnito info"
  value       = { "user_pool"        = aws_cognito_user_pool.user_pool.id
                  "identity_pool"    = aws_cognito_identity_pool.identity_pool.id
                  "auth_arn"         = aws_iam_role.authenticated.arn
                  "domain"           = "${aws_cognito_user_pool_domain.user_pool_domain.domain}.auth.${var.AWS_REGION}.amazoncognito.com"
                }
}