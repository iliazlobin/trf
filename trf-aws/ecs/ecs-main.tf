variable "env" {}
variable "vpc" {}
variable "tags" {}
variable "this" {}

resource "aws_lb" "this" {
  count              = var.this.aws_lb != null ? 1 : 0
  tags               = var.tags
  name               = var.tags.Name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.this.aws_lb.security_groups[*].id
  subnets            = var.this.aws_lb.subnets[*].id
}

resource "aws_lb_listener" "this" {
  count             = var.this.aws_lb_listener != null ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = var.this.aws_lb_listener.port
  protocol          = var.this.aws_lb_listener.protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }
}

resource "aws_lb_target_group" "this" {
  count       = var.this.aws_lb_target_group != null ? 1 : 0
  tags        = var.tags
  name        = var.tags.Name
  vpc_id      = var.vpc.aws_vpc.id
  port        = var.this.aws_lb_target_group.port
  protocol    = var.this.aws_lb_listener.protocol
  target_type = "instance"

  dynamic "health_check" {
    for_each = var.this.aws_lb_target_group.health_check != null ? [1] : []
    content {
      enabled             = var.this.aws_lb_target_group.health_check != null ? var.this.aws_lb_target_group.health_check.enabled != null ? var.this.aws_lb_target_group.health_check.enabled : null : null
      protocol            = var.this.aws_lb_target_group.health_check != null ? var.this.aws_lb_target_group.health_check.protocol != null ? var.this.aws_lb_target_group.health_check.protocol : null : null
      path                = var.this.aws_lb_target_group.health_check != null ? var.this.aws_lb_target_group.health_check.path != null ? var.this.aws_lb_target_group.health_check.path : null : null
      port                = var.this.aws_lb_target_group.health_check != null ? var.this.aws_lb_target_group.health_check.port != null ? var.this.aws_lb_target_group.health_check.port : null : null
      healthy_threshold   = var.this.aws_lb_target_group.health_check != null ? var.this.aws_lb_target_group.health_check.healthy_threshold != null ? var.this.aws_lb_target_group.health_check.healthy_threshold : null : null
      unhealthy_threshold = var.this.aws_lb_target_group.health_check != null ? var.this.aws_lb_target_group.health_check.unhealthy_threshold != null ? var.this.aws_lb_target_group.health_check.unhealthy_threshold : null : null
      interval            = var.this.aws_lb_target_group.health_check != null ? var.this.aws_lb_target_group.health_check.interval != null ? var.this.aws_lb_target_group.health_check.interval : null : null
      timeout             = var.this.aws_lb_target_group.health_check != null ? var.this.aws_lb_target_group.health_check.timeout != null ? var.this.aws_lb_target_group.health_check.timeout : null : null
      matcher             = var.this.aws_lb_target_group.health_check != null ? var.this.aws_lb_target_group.health_check.matcher != null ? var.this.aws_lb_target_group.health_check.matcher : null : null
    }
  }
}

resource "aws_ecs_cluster" "this" {
  tags = var.tags
  name = var.tags.Name
}

resource "aws_ecs_service" "this" {
  name            = var.tags.Name
  task_definition = aws_ecs_task_definition.this.arn
  iam_role        = var.this.aws_ecs_service.iam_role != null ? var.this.aws_ecs_service.iam_role.arn : null
  desired_count   = var.this.aws_ecs_service.desired_count
  cluster         = aws_ecs_cluster.this.name
  # deployment_maximum_percent         = 0
  # deployment_minimum_healthy_percent = 0
  launch_type = "EC2"

  # load_balancer = var.this.aws_ecs_service.load_balancer
  dynamic "load_balancer" {
    for_each = var.this.aws_ecs_service.load_balancer != null ? [1] : []
    content {
      container_name   = var.this.aws_ecs_service.load_balancer.container_name
      container_port   = var.this.aws_ecs_service.load_balancer.container_port
      target_group_arn = aws_lb_target_group.this.arn
    }
  }
  # load_balancer {
  #   target_group_arn = "${aws_lb_target_group.foo.arn}"
  #   container_name   = "mongo"
  #   container_port   = 8080
  # }

  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }
}

resource "aws_ecs_task_definition" "this" {
  family                = var.tags.Name
  execution_role_arn    = var.this.aws_ecs_task_definition.execution_role_arn != null ? var.this.aws_ecs_task_definition.execution_role_arn : null
  container_definitions = var.this.aws_ecs_task_definition.container_definitions
  # network_mode          = var.this.aws_ecs_task_definition.network_mode

  # volume {
  #   name      = "service-storage"
  #   host_path = "/ecs/service-storage"
  # }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }
}

output "this" {
  value = {

  }
}
