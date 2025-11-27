# userdata/ec2-userdata.tpl
# EC2 user-data that configures the instance as an ECS container host and installs stress-ng

#!/bin/bash
set -xe

# write ECS cluster name into ecs config (ECS agent will register this instance)
echo "ECS_CLUSTER=${ecs_cluster_name}" > /etc/ecs/ecs.config

# install stress-ng and ensure ecs agent on Amazon Linux 2
yum update -y
amazon-linux-extras install -y ecs
yum install -y stress-ng
systemctl enable --now ecs
