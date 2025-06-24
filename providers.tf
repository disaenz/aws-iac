provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "acm_east1"
  region = "us-east-1"
}