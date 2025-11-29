output "db_host" {
  value = aws_db_instance.main.address
}

output "ami_id" {
  value = data.aws_ami.php-app.id
}


