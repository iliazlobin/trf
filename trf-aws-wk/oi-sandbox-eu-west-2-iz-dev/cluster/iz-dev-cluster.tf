locals {
  env = {
    provider = "aws"
    aws = {
      profile = "oi-sandbox"
      region  = "eu-west-2"
    }
    name = "iz-dev"
  }
  tags = {
    Name = "${local.env.name}-coder-ecs"
  }
  ec2-tags = merge(local.tags, { Name = "${local.tags.Name}-ec2" })
  secrets = {
    ec2_public_key  = file("/c/home/.sec/ec2.key.pub")
  }
}

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.0"
  region  = local.env.aws.region
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path =   "/c/home/ws/trf/${local.env.aws.profile}-${local.env.aws.region}-${local.env.name}/vpc/terraform.tfstate"
  }
}

locals {
  vpc = data.terraform_remote_state.vpc.outputs.this
  instance_type = "t3.small"
}

module "master-node-a" {
  source = "/c/home/ws/trf/trf-aws/ec2"
  env    = local.env
  vpc    = local.vpc
  tags = merge(local.tags, { Name = "${local.tags.Name}-master-node-a" })
  aws_instance-instance_type = local.instance_type

  this = {
    
    aws_instance = {

    }
    aws_key_pair = {
      public_key = local.secrets.ec2_public_key
    }
    aws_iam_instance_profile = {
      aws_iam_role = aws_iam_role.coder-ecs-ec2
    }
  }
}
