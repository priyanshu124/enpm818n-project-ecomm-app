#!/bin/bash
set -ex

###########################################
# Register instance to ECS cluster
###########################################
echo "ECS_CLUSTER=${ecs_cluster_name}" > /etc/ecs/ecs.config


###########################################
# Install dependencies
###########################################
yum update -y
yum install -y java-1.8.0-openjdk unzip wget stress-ng

###########################################
# Install Apache JMeter
###########################################
JMETER_VERSION="5.5"
cd /opt
wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz
tar -xzf apache-jmeter-$JMETER_VERSION.tgz
ln -s /opt/apache-jmeter-$JMETER_VERSION /opt/jmeter

echo 'export JMETER_HOME=/opt/jmeter' >> /etc/profile.d/jmeter.sh
echo 'export PATH=$JMETER_HOME/bin:$PATH' >> /etc/profile.d/jmeter.sh
source /etc/profile.d/jmeter.sh

chmod -R 755 /opt/apache-jmeter-$JMETER_VERSION
