# KMS key, DB subnet group, parameter group to enforce SSL, and RDS MySQL instance

# KMS key to encrypt RDS storage at rest
resource "aws_kms_key" "rds_key" {
  description = "KMS key for ${var.prefix} RDS encryption"
  tags        = { Name = "${var.prefix}-kms-rds" }
}

# DB subnet group covering private subnets for the RDS instance
resource "aws_db_subnet_group" "main" {
  name = "${local.prefix}-main"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = merge(
    local.common_tags,
    { "Name" = "${local.prefix}-main" }
  )
}

# Parameter group to require SSL/TLS for MySQL connections
resource "aws_db_parameter_group" "ssl" {
  name   = "${var.prefix}-mysql-ssl"
  family = "mysql8.0"
  parameter {
    name  = "require_secure_transport"
    value = "ON"
  }
}


resource "aws_db_instance" "main" {
  identifier                 = "${local.prefix}-db"
  allocated_storage          = 20
  storage_type               = "gp2"
  engine                     = "mysql"
  engine_version             = "8.0"
  instance_class             = "db.t3.micro"
  db_subnet_group_name       = aws_db_subnet_group.main.name
  password                   = var.db_password
  username                   = var.db_username
  backup_retention_period    = 0
  multi_az                   = true
  publicly_accessible        = false
  skip_final_snapshot        = true
  auto_minor_version_upgrade = true
  storage_encrypted          = true
  kms_key_id                 = aws_kms_key.rds_key.arn
  vpc_security_group_ids     = [aws_security_group.rds.id]
  parameter_group_name       = aws_db_parameter_group.ssl.name

  tags = merge(
    local.common_tags,
    { "Name" = "${local.prefix}-main" }
  )
}


resource "aws_secretsmanager_secret" "rds_secret" {
  name        = "enpm818n-rds-credentials"
  description = "RDS credentials for ecommerce app"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.main.address
    dbname   = var.db_name
    port     = 3306
  })
}

