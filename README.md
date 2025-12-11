ENPM818N – Scalable & Secure E-Commerce Platform on AWS

🚀 Objective

The objective of this project is to design, deploy, and secure a highly available, auto-scaling, and fully monitored e-commerce application on AWS. The implementation emphasizes scalability, performance optimization, cost efficiency, and strong security controls.
Core infrastructure components were provisioned using Terraform, while AWS WAF, WAF logging, and CloudWatch dashboards were initially configured manually through the AWS Console and later converted into Infrastructure-as-Code using stack YAML templates.
System resiliency and elasticity were validated through JMeter load testing, demonstrating real-world scaling and fault-tolerance behavior.

✨ Features Implemented

1. Infrastructure Deployment with Terraform

Automated provisioning of core AWS resources:

Custom VPC with public and private subnets

EC2 Auto Scaling Group with Launch Template and custom AMI

Application Load Balancer (HTTPS enabled)

RDS MySQL with Multi-AZ and AWS KMS encryption

S3 Bucket for static asset hosting

CloudFront CDN for caching & performance optimization

NAT Gateway, route tables, IAM roles, and logs

CloudWatch alarms for CPU, network, error rates, latency

Naming standard enforced using prefix enpm818n-*


2. Security Architecture

AWS WAF for protection against SQLi, XSS, malicious bots

WAF logs → CloudWatch Logs

TLS/HTTPS via ACM

Secrets Manager for secure DB credentials

KMS encryption for RDS at rest

IAM roles with least-privilege access


3. Database Layer (RDS MySQL)

Multi-AZ for high availability

Encrypted at rest with AWS KMS

Encrypted in transit with SSL

Tables for products, users, orders

CRUD operations verified through the e-commerce admin panel


4. Content Delivery & Performance Optimization

CloudFront used as global CDN for static & cached content

S3 origin for media and static assets

Dynamic caching rules applied

GZIP compression enabled through the ALB and CloudFront

CloudWatch alarms for latency and 5xx error rates


5. Monitoring & Logging

CloudWatch dashboards for:

EC2 CPU utilization

NetworkOut / NetworkIn

ALB request count & latency

5xx error rates

CloudTrail enabled for account-level audit logging

WAF access logs and block logs integrated


6. Auto Scaling & Performance Testing

Auto Scaling configured with:

CPU-based alarms (enpm818n-cpu-*)

Custom NetworkOut alarms (enpm818n-custom-*)

Scale-in and scale-out thresholds applied

ASG validated during load testing

JMeter used for:

Load testing ALB & EC2

Monitoring scaling events

Observing DB query performance under load


🧰 Tools & Technologies Used
Infrastructure as Code

Terraform

AWS CloudFormation (stack YAML templates for WAF & logging)

Compute

EC2, Auto Scaling Group, Launch Templates

Networking

VPC, IGW, NAT Gateway, Route Tables, Security Groups

Storage & CDN

S3, CloudFront

Database

RDS MySQL, KMS encryption, Secrets Manager

Security

WAF, ACLs, ACM, IAM

Monitoring

CloudWatch Logs & Dashboards

CloudTrail

CloudWatch Alarms

Testing

JMeter

stress-ng (pre-installed in custom AMI)


📌 Key Outcomes

Highly available, elastic cloud application

Strong security posture (WAF, TLS, encryption-at-rest)

CDN acceleration reducing page load times

Fully monitored system with dashboards & alerts

Terraform + stack templates enable full reproducibility

Load testing validates fault tolerance & horizontal scaling
