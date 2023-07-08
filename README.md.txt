# Terraform AWS Infrastructure Deployment

This Terraform code provisions an AWS infrastructure with the following components:

- VPC with two subnets
- Internet Gateway and route table for internet connectivity
- Security group for EC2 instances
- EC2 instance with Apache web server installed
- RDS database instance
- Application Load Balancer with target group
- Auto Scaling Group with launch configuration and scaling policy

## Prerequisites

Before running this Terraform code, make sure you have the following:

- AWS account with appropriate credentials
- Terraform installed locally

## Usage

1. Clone the repository:

```shell
git clone <repository-url>

Initialize Terraform:
	terraform init

Review and modify the terraform.tfvars file to configure any required variables.
Check for the services that are beeing added:
	terraform plan
Deploy the infrastructure:
	terraform apply

Verify that the infrastructure has been created successfully.
Clean up and destroy the infrastructure when no longer needed:
	terraform destroy

Configuration
	Make sure to update the following variables in terraform.tfvars before running terraform apply:
	access_key: Your AWS access key.
	secret_key: Your AWS secret key.
You can also modify other variables such as the region, CIDR blocks, AMI IDs, and resource names according to your requirements.

Contributions
	Contributions to enhance this Terraform code are welcome! If you find any issues or have suggestions for improvement, please open an issue or submit a pull request.

What Services are included:
VPC (Virtual Private Cloud): The code creates a VPC with a specified CIDR block, allowing you to define your private network space in AWS.

Subnets: The code creates two subnets within the VPC. Subnets allow you to segment your VPC into smaller networks and distribute resources across different availability zones for high availability.

Internet Gateway: An Internet Gateway is created to enable internet connectivity for resources within the VPC. It allows inbound and outbound internet traffic.

Route Table: A route table is associated with the VPC, providing rules for routing traffic between subnets and the internet. The code also creates a route that directs internet-bound traffic to the Internet Gateway.

Security Group: The code defines a security group that acts as a virtual firewall for the EC2 instance. It allows inbound SSH (port 22) access from any IP address and outbound HTTP (port 80) and HTTPS (port 443) access to the internet.

EC2 Instance: An EC2 instance is launched with the specified Amazon Machine Image (AMI), instance type, and key pair. The instance is associated with the previously created subnet and security group. Additionally, a user data script is provided to install Apache web server and create a simple "Hello, World!" HTML page.

RDS Instance: The code provisions an RDS database instance with the specified engine, engine version, instance class, storage settings, and security group. The database instance is associated with the previously created DB subnet group.

Load Balancer: An Application Load Balancer (ALB) is created with the specified name and load balancer type. It distributes incoming traffic across multiple instances within the specified subnets.

Target Group: A target group is created to group the instances behind the ALB. The target group listens on port 80 using HTTP protocol.

Auto Scaling Group: An Auto Scaling Group (ASG) is created to manage the scaling of EC2 instances. It specifies the minimum and maximum number of instances, desired capacity, health check grace period, and references the launch configuration.

Launch Configuration: A launch configuration is defined with the specified AMI, instance type, key pair, security group, and user data script. The launch configuration serves as a template for creating instances within the ASG.

Scaling Policy: A scaling policy is created to automatically scale the ASG based on the average CPU utilization of the instances. It adjusts the number of instances to maintain a target CPU utilization of 50%.