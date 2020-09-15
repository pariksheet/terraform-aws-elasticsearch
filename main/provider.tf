provider "aws" {
  region = var.AWS_REGION
  version = "~> 3.5"
}

provider "random" {
  version = "~> 2.3"
}

provider "template" {
  version = "~> 2.1"
}

provider "null" {
  version = "~> 2.1"
}