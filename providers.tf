provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "east1"
  region = "us-east-1"
}