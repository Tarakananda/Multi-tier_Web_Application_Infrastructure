terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = "us-east-1"
  access_key = "AKIARBBGJ4FIU5ORKKMF" #"provide_your_access_key"
  secret_key = "sB9ZuOeWau2huqUrl3EBZov5k1JPSosuV0ywAEpK" #"provide_your_secret_key"
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Subnets
resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Replace with your desired availability zone
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"  # Replace with your desired availability zone
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create Route
resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "subnet_2_association" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.my_route_table.id
}


# Create Security Group
resource "aws_security_group" "instance_sg" {
  vpc_id      = aws_vpc.my_vpc.id
  name        = "instance_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Launch EC2 Instance
resource "aws_instance" "my_instance" {
  ami           = "ami-053b0d53c279acc90" # Replace with your desired AMI ID
  instance_type = "t2.micro"
  key_name = "sublister"
  subnet_id     = aws_subnet.subnet_1.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]



  tags = {
    Name = "my_instance"
  }
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name        = "my-db-subnet-group"
  description = "My DB Subnet Group"
  subnet_ids  = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id] 
}


# Create RDS Instance
resource "aws_db_instance" "my_rds_instance" {
  identifier           = "my-rds-instance"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  username             = "admin"
  password             = "password"
  publicly_accessible = false
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
}

# Create Load Balancer
resource "aws_lb" "my_load_balancer" {
  name               = "my-load-balancer"
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
}

# Create Target Group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

# Attach EC2 Instance to Target Group
resource "aws_lb_target_group_attachment" "my_target_group_attachment" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_instance.id
  port             = 80
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "my_autoscaling_group" {
  name                 = "my-autoscaling-group"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  health_check_grace_period = 300
  vpc_zone_identifier  = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  launch_configuration = aws_launch_configuration.my_launch_configuration.name
}

# Create Launch Configuration
resource "aws_launch_configuration" "my_launch_configuration" {
  name                 = "my-launch-configuration"
  image_id             = "ami-053b0d53c279acc90" # Replace with your desired AMI ID
  instance_type        = "t2.micro"
  key_name             = aws_instance.my_instance.key_name
  security_groups      = [aws_security_group.instance_sg.id]
  user_data = <<-EOF
                    #!/bin/bash
                    apt-get update
                    apt-get install -y apache2
                    systemctl enable apache2
                    systemctl start apache2
                    echo "Hello, World!" > /var/www/html/index.html
                EOF
}

# Create Scaling Policy
resource "aws_autoscaling_policy" "my_scaling_policy" {
  name                   = "my-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.my_autoscaling_group.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
