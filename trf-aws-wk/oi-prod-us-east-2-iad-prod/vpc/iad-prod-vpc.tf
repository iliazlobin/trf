locals {
  env = {
    provider = "aws"
    aws = {
      profile = "oi-prod"
      region = "eu-west-2"
    }
    name = "prod"
  }
  tags = {
    Name = local.env.name
  }
  secrets = {
  }
}

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.0"
  region  = local.env.aws.region
}

module "vpc" {
  source = "/c/home/ws/trf/trf-aws/vpc"
  env = local.env
  tags = merge({ Name = "${local.tags.Name}-vpc" }, local.tags)
  
  this = {
    aws_vpc-data = {
      id = "vpc-05ef175809e2f47dc"
    }
    aws_eip-data = {
      id = "eipalloc-0f6c5e2c465b6bf20"
    }
    aws_nat_gateway-data = {
      id = "nat-0d5a642507225b01d"
    }
    aws_internet_gateway-data = {
      internet_gateway_id = "igw-002b73d4ec5621a5c"
    }
    ntw-public = {
      aws_subnet-data-list = [
        {
          id = "subnet-032fc33b798cb09d2"
        },
        {
          id = "subnet-08d2bc3c35fffafc9"
        },
        {
          id = "subnet-0279822124b05f055"
        },
      ]
    }
    ntw-private = {
      aws_subnet-data-list = [
        {
          id = "subnet-0295377b68bf20f2f"
        },
        {
          id = "subnet-065d5e13af66c3834"
        },
        {
          id = "subnet-06b320b8262697317"
        },
      ]
    }
  }
}

output "this" { value = module.vpc.this }
