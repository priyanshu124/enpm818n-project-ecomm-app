
# ECS cluster, launch template and auto scaling group to run EC2 container hosts

# ECS cluster to register EC2 container instances
resource "aws_ecs_cluster" "cluster" {
  # Logical ECS cluster for managing tasks and services
  name = "${var.prefix}-ecs-cluster"
  tags = merge(
    local.common_tags,
    { "Name" = "${local.prefix}-main" }
  )
}



