
# IAM roles & instance profile to allow EC2 to run ECS agent, pull from ECR, read Secrets/SSM, and send logs


# Role for EC2 instances (ECS container host)
resource "aws_iam_role" "ec2_instance_role" {
  # Role attached to EC2 instances so they can run ECS agent and perform actions
  name               = "${var.prefix}-ec2-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach AWS managed policy that provides ECS instance permissions
resource "aws_iam_role_policy_attachment" "ecs_managed" {
  # Enables EC2 to be an ECS container instance
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  depends_on = [aws_iam_role.ec2_instance_role]
}


# Instance profile for EC2 to attach the role
resource "aws_iam_instance_profile" "ec2_profile" {
  # Instance profile used by the Launch Template to give EC2 the IAM role
  name = "${var.prefix}-ec2-profile"
  role = aws_iam_role.ec2_instance_role.name
  depends_on = [aws_iam_role.ec2_instance_role]
}


resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.prefix}-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  depends_on = [aws_iam_role.ec2_instance_role]
}

# Attach AWS managed policy
resource "aws_iam_role_policy_attachment" "ecs_execution_managed" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  depends_on = [aws_iam_role.ecs_execution_role]
}

# Extra permissions (S3, CloudWatch, Secrets)
resource "aws_iam_role_policy" "ecs_execution_extra" {
  name   = "${var.prefix}-ecs-execution-extra"
  role   = aws_iam_role.ecs_execution_role.id
  policy = file("./templates/ecs/ecs-execution-role.json")
  depends_on = [aws_iam_role.ecs_execution_role]
}


resource "aws_iam_role" "ecs_task_role" {
  name = "${var.prefix}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  depends_on = [ aws_iam_role.ec2_instance_role, aws_iam_role.ecs_execution_role]
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name   = "${var.prefix}-ecs-task-policy"
  role   = aws_iam_role.ecs_task_role.id
  policy = file("./templates/ecs/ecs-task-role.json")
  depends_on = [aws_iam_role.ecs_task_role]
}

