packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">=1.0.0"
    }
  }
}

source "amazon-ebs" "php" {
  region        = "us-east-1"
  instance_type = "t3.micro"
  ssh_username  = "ec2-user"

  ami_name = "php-app-{{timestamp}}"
  iam_instance_profile = "enpm818n-ec2-profile"

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-ebs"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["137112412989"]  # Amazon official owner ID for Amazon Linux 2
    most_recent = true
  }
}

build {
  name    = "php-app-build"
  sources = ["source.amazon-ebs.php"]

  # Upload local PHP app
  provisioner "file" {
    source      = "../app"
    destination = "/home/ec2-user/app"
    
  }

  provisioner "shell" {
    inline = [
      "sudo yum update -y",


      # Install packages
      "sudo amazon-linux-extras enable php8.0",
      "sudo yum clean metadata",
      "sudo yum install -y httpd php php-mysqlnd php-mbstring php-json php-cli mysql unzip wget stress-ng tar jq",

       # Fetch RDS secret from Secrets Manager
      "SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id enpm818n-rds-credentials --region us-east-1 --query 'SecretString' --output text)",
      "DB_HOST=$(echo $SECRET_JSON | jq -r .host)",
      "DB_USER=$(echo $SECRET_JSON | jq -r .username)",
      "DB_PASSWORD=$(echo $SECRET_JSON | jq -r .password)",
      "DB_NAME=$(echo $SECRET_JSON | jq -r .dbname)",
      "DB_PORT=$(echo $SECRET_JSON | jq -r .port)",


      # Set environment variables for PHP via Apache
      "echo 'SetEnv CDN_URL https://assets.enpm818n-ecomm-app.xyz/' | sudo tee /etc/httpd/conf.d/app-env.conf",
      "echo \"SetEnv DB_HOST $DB_HOST\" | sudo tee -a /etc/httpd/conf.d/app-env.conf",
      "echo \"SetEnv DB_USER $DB_USER\" | sudo tee -a /etc/httpd/conf.d/app-env.conf",
      "echo \"SetEnv DB_PASSWORD $DB_PASSWORD\" | sudo tee -a /etc/httpd/conf.d/app-env.conf",
      "echo \"SetEnv DB_NAME $DB_NAME\" | sudo tee -a /etc/httpd/conf.d/app-env.conf",
      "echo \"SetEnv DB_PORT $DB_PORT\" | sudo tee -a /etc/httpd/conf.d/app-env.conf",

      # Copy application
      "sudo mkdir -p /var/www/html",
      "sudo cp -r /home/ec2-user/app/* /var/www/html",
      "sudo chown -R apache:apache /var/www/html",

      # RDS certs
      "sudo wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -O /etc/ssl/certs/rds-combined-ca-bundle.pem",
      "sudo chmod 644 /etc/ssl/certs/rds-combined-ca-bundle.pem",

      # Install JMeter
      "sudo wget https://downloads.apache.org/jmeter/binaries/apache-jmeter-5.6.3.tgz -P /tmp",
      "sudo tar -xzf /tmp/apache-jmeter-5.6.3.tgz -C /opt --no-same-owner",
      "sudo ln -s /opt/apache-jmeter-5.6.3/bin/jmeter /usr/local/bin/jmeter",

      # Reload systemd and enable/start services
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"

    ]
  }
}
