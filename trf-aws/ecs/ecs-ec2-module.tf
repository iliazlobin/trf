module "ec2" {
  source                = "/c/home/ws/trf/trf-aws/ec2"
  env                   = var.env
  tags                  = var.this.ec2.tags
  this = {
    aws_lb                = var.this.ec2.aws_lb
    aws_autoscaling_group = var.this.ec2.aws_autoscaling_group
    aws_launch_template = {
      vpc_security_group_ids = var.this.ec2.aws_launch_template.vpc_security_group_ids
      image_id               = var.this.ec2.aws_launch_template.image_id
      instance_type          = var.this.ec2.aws_launch_template.instance_type
      # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html
      # ECS_CONTAINER_INSTANCE_TAGS={"tag_key": "tag_value"}
      user_data = <<-EOT
        #!/bin/bash
        cat <<'EOD' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${aws_ecs_cluster.this.name}
        EOD
      EOT
    }
    aws_key_pair             = var.this.ec2.aws_key_pair
    aws_iam_instance_profile = var.this.ec2.aws_iam_instance_profile
  }
}
