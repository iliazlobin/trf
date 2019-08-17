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
    docker_hub_auth = file("/c/home/.sec/hub.docker.com.json")
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
    path = "/c/home/ws/trf/${local.env.aws.profile}-${local.env.aws.region}-${local.env.name}/vpc/terraform.tfstate"
  }
}

locals {
  vpc = data.terraform_remote_state.vpc.outputs.this
}

module "coder-ecs" {
  source = "/c/home/ws/trf/trf-aws/ecs"
  env    = local.env
  vpc    = local.vpc
  tags   = local.tags
  this = {
    # aws_lb = {
    #   security_groups = [aws_security_group.coder-ecs-aws_lb]
    #   subnets         = local.vpc.ntw-public.aws_subnet-list
    # }
    # aws_lb_listener = {
    #   port     = 8443
    #   protocol = "HTTP"
    # }
    # aws_lb_target_group = {
    #   port     = 8443
    #   protocol = "HTTP"
    #   health_check = {
    #     enabled             = true
    #     healthy_threshold   = 2
    #     unhealthy_threshold = 3
    #     timeout             = 5
    #     interval            = 60
    #     matcher             = "200-499"
    #     port                = null
    #     path                = null
    #     protocol            = null
    #   }
    # }
    aws_lb              = null
    aws_lb_listener     = null
    aws_lb_target_group = null
    aws_ecs_service = {
      # iam_role      = aws_iam_role.coder-ecs
      iam_role      = null
      desired_count = 1
      # load_balancer = {
      #   container_name = "coder"
      #   container_port = 8443
      # }
      load_balancer = null
    }
    # https://docs.aws.amazon.com/AmazonECS/latest/userguide/task_definition_parameters.html
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
    aws_ecs_task_definition = {
      execution_role_arn    = aws_iam_role.coder-ecs-tasks.arn
      container_definitions = <<-EOT
        [
          {
            "name": "coder",
            "repositoryCredentials": {
              "credentialsParameter": "${aws_secretsmanager_secret.coder.arn}"
            },
            "image": "iliazlobin/env",
            "cpu": 1500,
            "memory": 3500,
            "essential": true,
            "portMappings": [
              {
                "containerPort": 8443
              }
            ],
            "logConfiguration": {
              "logDriver": "awslogs",
              "options": {
                "awslogs-group": "${local.tags.Name}",
                "awslogs-region": "${local.env.aws.region}",
                "awslogs-stream-prefix": "${local.tags.Name}"
              }
            }
          }
        ]
      EOT
    }
    ec2 = {
      tags   = local.ec2-tags
      aws_lb = null
      aws_autoscaling_group = {
        max_size                  = 1
        min_size                  = 1
        desired_capacity          = 1
        health_check_grace_period = 30
        vpc_zone_identifier       = local.vpc.ntw-public.aws_subnet-list
        # target_group_arns = [aws_lb_target_group.coder-ecs-ec2]
        health_check_type         = null
        health_check_grace_period = null
      }
      aws_launch_template = {
        vpc_security_group_ids = [aws_security_group.coder-ecs-ec2-aws_launch_template]
        image_id               = "ami-0de1dc478496a9e9b"
        instance_type          = "t3.medium"
        user_data = null
      }
      aws_key_pair = {
        public_key = local.secrets.ec2_public_key
      }
      aws_iam_instance_profile = {
        aws_iam_role = aws_iam_role.coder-ecs-ec2
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "coder" {
  name              = local.tags.Name
  retention_in_days = 1
}

resource "aws_iam_role" "coder-ecs-ec2" {
  tags               = local.ec2-tags
  name               = local.ec2-tags.Name
  assume_role_policy = data.aws_iam_policy_document.coder-ecs-ec2-assume_role.json
}

data "aws_iam_policy_document" "coder-ecs-ec2-assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "coder-ecs-ec2" {
  name   = local.ec2-tags.Name
  role   = aws_iam_role.coder-ecs-ec2.id
  policy = data.aws_iam_policy_document.coder-ecs-ec2-policy.json
}

data "aws_iam_policy_document" "coder-ecs-ec2-policy" {
  statement {
    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "coder-ecs" {
  tags               = local.tags
  name               = local.tags.Name
  assume_role_policy = data.aws_iam_policy_document.coder-ecs-assume_role.json
}

data "aws_iam_policy_document" "coder-ecs-assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "coder-ecs-service_scheduler" {
  role       = aws_iam_role.coder-ecs.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy" "coder-ecs" {
  name   = local.tags.Name
  role   = aws_iam_role.coder-ecs.id
  policy = data.aws_iam_policy_document.coder-ecs-policy.json
}

data "aws_iam_policy_document" "coder-ecs-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "coder-ecs-tasks" {
  tags               = merge(local.tags, { Name = "${local.tags.Name}-tasks" })
  name               = "${local.tags.Name}-tasks"
  assume_role_policy = data.aws_iam_policy_document.coder-ecs-tasks-assume_role.json
}

data "aws_iam_policy_document" "coder-ecs-tasks-assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "coder-ecs-tasks" {
  name   = "${local.tags.Name}-tasks"
  role   = aws_iam_role.coder-ecs-tasks.id
  policy = data.aws_iam_policy_document.coder-ecs-tasks-policy.json
}

data "aws_iam_policy_document" "coder-ecs-tasks-policy" {
  statement {
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_secretsmanager_secret.coder.arn,
    ]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_security_group" "coder-ecs-aws_lb" {
  tags        = merge(local.ec2-tags, { Name = "${local.ec2-tags.Name}-lb" })
  name        = "${local.ec2-tags.Name}-lb"
  description = "${local.ec2-tags.Name}-lb"
  vpc_id      = local.vpc.aws_vpc.id
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "TCP"
    cidr_blocks = ["86.57.255.88/29"]
    description = "EPAM subnet"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "coder-ecs-ec2-aws_launch_template" {
  tags        = merge(local.ec2-tags, { Name = "${local.ec2-tags.Name}-asg" })
  name        = "${local.ec2-tags.Name}-asg"
  description = "${local.ec2-tags.Name}-asg"
  vpc_id      = local.vpc.aws_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["86.57.255.88/29"]
    description = "EPAM subnet: ssh"
  }
  ingress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "TCP"
    security_groups = [aws_security_group.coder-ecs-aws_lb.id]
  }
  ingress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "TCP"
    cidr_blocks = ["86.57.255.88/29"]
    description     = "EPAM subnet: code server"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_secretsmanager_secret" "coder" {
  name                    = local.tags.Name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "coder" {
  secret_id     = aws_secretsmanager_secret.coder.id
  secret_string = local.secrets.docker_hub_auth
  # secret_string = "${jsonencode(map("username", "${data.vault_generic_secret.iad_bitbucket_user.data["name"]}", "password", "${data.vault_generic_secret.iad_bitbucket_user.data["password"]}"))}"
}

# data "vault_generic_secret" "iad_bitbucket_user" {
#   path = "secret/iad/global/iad_bitbucket_user"
# }
