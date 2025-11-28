
# ECS cluster, launch template and auto scaling group to run EC2 container hosts

# ECS cluster to register EC2 container instances
resource "aws_ecs_cluster" "cluster" {
  # Logical ECS cluster for managing tasks and services
  name = "${var.prefix}-ecs-cluster"
  tags = merge(
    local.common_tags,
    { "Name" = "${local.prefix}-ecs-cluster" }
  )
}

# ECS task definition and ECS service (EC2 launch type) registering with ALB target group

# ECR authorization token is used by ECS/hosts to pull images
data "aws_ecr_authorization_token" "token" {}

# ECS task definition describing container settings and environment
resource "aws_ecs_task_definition" "app_task" {
  # Describes the PHP container that will be run as part of the ECS service
  family                   = "${var.prefix}-ecommerce-app-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = aws_iam_role.ec2_role.arn
  execution_role_arn       = aws_iam_role.ec2_role.arn

  container_definitions = jsonencode([{
    name         = "ecommerce-app"
    image        = "${var.ecr_repo_url}:latest"
    cpu          = 256
    memory       = 512
    essential    = true
    portMappings = [{ containerPort = 80, hostPort = 0 }]
    environment = [
      { name = "DB_HOST", value = aws_db_instance.main.address },
      { name = "DB_USER", value = var.db_username },
      { name = "DB_NAME", value = var.db_name }
      # DB password should be loaded securely via Secrets Manager in production
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.prefix}"
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecommerce-app"
      }
    }
  }])
}

# ECS Service to keep desired count of tasks running and register with ALB
resource "aws_ecs_service" "app_service" {
  # Service maintains tasks and integrates with ALB for load balancing
  name            = "${var.prefix}-appservice"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "ecommerce-app"
    container_port   = 80
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  depends_on = [aws_lb_listener.https]
}


