
# Create a VPC
resource "aws_vpc" "Chris_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "chris_vpc",
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "chris_igw" {
  vpc_id = aws_vpc.Chris_vpc.id
  tags = {
    Name = "chris-internet-gateway"
  }
}
#create route table rule
resource "aws_route_table" "chris_route_table" {
  vpc_id = aws_vpc.Chris_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chris_igw.id
  }
  tags = {
    Name = "chris_route_table"
  }
}


# Create a public subnet1
resource "aws_subnet" "chris_public_subnet1" {
  vpc_id                  = aws_vpc.Chris_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "chris_public-subnet1"
  }
}

# Create a public subnet2
resource "aws_subnet" "chris_public_subnet2" {
  vpc_id                  = aws_vpc.Chris_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "chris_public-subnet2"
  }
}

# Create a public subnet3
resource "aws_subnet" "chris_public_subnet3" {
  vpc_id                  = aws_vpc.Chris_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "chris_public-subnet3"
  }
}

# Create security group
resource "aws_security_group" "chris_group" {
  vpc_id = aws_vpc.Chris_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access from anywhere"
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow container access"
  }
   ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow container access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS access from anywhere"
  }

  # Egress rules (outgoing traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all traffic
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "chris-security-group"
  }
}

# Define the first EC2 instance
resource "aws_instance" "my_first_instance" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.chris_public_subnet1.id
  security_groups = [aws_security_group.chris_group.id]
  key_name = var.key_name

  tags = {
    Name = "my_first_instance"
  }
}

# Define the second EC2 instance
resource "aws_instance" "my_second_instance" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.chris_public_subnet2.id
  security_groups = [aws_security_group.chris_group.id]
  key_name = var.key_name

  tags = {
    Name = "my_second_instance"
  }
}

# Define the third EC2 instance
resource "aws_instance" "my_third_instance" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.chris_public_subnet3.id
  security_groups = [aws_security_group.chris_group.id]
  key_name = var.key_name

  tags = {
    Name = "my_third_instance"
  }
}

# create launch launch_configuration for aws_autoscaling_group
resource "aws_launch_configuration" "chris_launch_configuration" {
  name          = "chris_launch_configuration"
  image_id      = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.chris_group.id]
}

# Define the Auto Scaling Group
resource "aws_autoscaling_group" "chris_autoscaling_group" {
  desired_capacity     = 1
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.chris_public_subnet1.id, aws_subnet.chris_public_subnet2.id, aws_subnet.chris_public_subnet3.id]
  launch_configuration = aws_launch_configuration.chris_launch_configuration.id
}

#  associating the route table to different subnet1
resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.chris_public_subnet1.id
  route_table_id = aws_route_table.chris_route_table.id
}

#  associating the route table to different subnet2
resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.chris_public_subnet2.id
  route_table_id = aws_route_table.chris_route_table.id
}

resource "aws_route_table_association" "subnet3" {
  subnet_id      = aws_subnet.chris_public_subnet3.id
  route_table_id = aws_route_table.chris_route_table.id
}

# creating loadbalancer
resource "aws_lb" "chris_lb" {
  name               = "chrislb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.chris_group.id]
  subnets            = [aws_subnet.chris_public_subnet1.id, aws_subnet.chris_public_subnet2.id, aws_subnet.chris_public_subnet3.id]
  tags = {
    name = "chris_loadbalancer"
  }
}

resource "aws_lb_target_group" "chris_target_group" {
  name     = "chris-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Chris_vpc.id

  health_check {
    path = "/"
  }
  tags = {
    Name = "chris-target-group"
  }
}
resource "aws_lb_target_group_attachment" "chris-lbtg1" {
  target_group_arn = aws_lb_target_group.chris_target_group.arn
  target_id        = aws_instance.my_first_instance.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "chris-lbtg2" {
  target_group_arn = aws_lb_target_group.chris_target_group.arn
  target_id        = aws_instance.my_second_instance.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "chris-lbtg3" {
  target_group_arn = aws_lb_target_group.chris_target_group.arn
  target_id        = aws_instance.my_third_instance.id
  port             = 80
}


resource "aws_lb_listener" "httplistener" {
  load_balancer_arn = aws_lb.chris_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chris_target_group.arn
  }
}



output "public_ip1" {
  value = aws_instance.my_first_instance.public_ip
}
output "public_ip2" {
  value = aws_instance.my_second_instance.public_ip
}
output "public_ip3" {
  value = aws_instance.my_third_instance.public_ip
}
