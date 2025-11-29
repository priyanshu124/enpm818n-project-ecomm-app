# Application Load Balancer, target group, HTTPS listener using ACM certificate, and basic WAF

# ALB to distribute HTTP/HTTPS traffic to EC2 instances
resource "aws_lb" "alb" {
  name               = "${var.prefix}-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups    = [aws_security_group.alb.id]
  tags = merge(
    local.common_tags,
    { "Name" = "${local.prefix}-alb" }
  )
}


# Target group for app (EC2 instances)
resource "aws_lb_target_group" "app" {
  name     = "${var.prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  target_type = "instance"
  health_check {
    path    = "/"
    matcher = "200-399"
  }

  tags = merge(
    local.common_tags,
    { "Name" = "${local.prefix}-alb-tg" }
  )
}

# ALB HTTPS listener using ACM certificate
resource "aws_lb_listener" "https" {
  # Accepts HTTPS traffic and forwards to the app target group
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.ssl.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
