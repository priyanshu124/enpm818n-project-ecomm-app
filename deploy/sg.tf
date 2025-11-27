# ALB SG
resource "aws_security_group" "alb" {
  name        = "${var.prefix}-alb-sg"
  vpc_id      = aws_vpc.main.id
  description = "ALB security group"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    local.common_tags,
    { "Name" = "${var.prefix}-alb-sg" }
  )
}

# EC2 (ECS container instances) SG
resource "aws_security_group" "ecs" {
  name        = "${var.prefix}-ecs-sg"
  vpc_id      = aws_vpc.main.id
  description = "ECS EC2 instances security group"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    local.common_tags,
    { "Name" = "${var.prefix}-ecs-sg" }
  )
}

# RDS SG
resource "aws_security_group" "rds" {
  name        = "${var.prefix}-rds-sg"
  vpc_id      = aws_vpc.main.id
  description = "RDS security group"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    local.common_tags,
    { "Name" = "${var.prefix}-rds-sg" }
  )
}
