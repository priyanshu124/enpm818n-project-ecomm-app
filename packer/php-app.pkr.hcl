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
      "sudo yum install -y httpd php php-mysqlnd php-mbstring php-json php-cli unzip wget stress-ng tar",

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
