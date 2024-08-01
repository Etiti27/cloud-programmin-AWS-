
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

# Create a public subnet
resource "aws_subnet" "chris_public_subnet1" {
  vpc_id                  = aws_vpc.Chris_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "chris_public-subnet1"
  }
}

# Create a public subnet
resource "aws_subnet" "chris_public_subnet2" {
  vpc_id                  = aws_vpc.Chris_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "chris_public-subnet2"
  }
}
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
    Name = "my-security-group"
  }
}

# Define the first EC2 instance
resource "aws_instance" "my_first_instance" {
  ami             = "ami-04a81a99f5ec58529"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.chris_public_subnet1.id
  security_groups = [aws_security_group.chris_group.id]

  tags = {
    Name = "my_first_instance"
  }
}

# Define the second EC2 instance
resource "aws_instance" "my_second_instance" {
  ami             = "ami-04a81a99f5ec58529"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.chris_public_subnet2.id
  security_groups = [aws_security_group.chris_group.id]

  tags = {
    Name = "my_second_instance"
  }
}

# Define the third EC2 instance
resource "aws_instance" "my_third_instance" {
  ami             = "ami-04a81a99f5ec58529"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.chris_public_subnet3.id
  security_groups = [aws_security_group.chris_group.id]

  tags = {
    Name = "my_third_instance"
  }
}


resource "aws_launch_configuration" "chris_launch_configuration" {
  name          = "chris_launch_configuration"
  image_id      = "ami-04a81a99f5ec58529"  
  instance_type = "t2.micro"
}

# Define the Auto Scaling Group
resource "aws_autoscaling_group" "chris_autoscaling_group" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.chris_public_subnet1.id, aws_subnet.chris_public_subnet2.id,aws_subnet.chris_public_subnet3.id]
  launch_configuration = aws_launch_configuration.chris_launch_configuration.id
}











# Create a route table
# resource "aws_route_table" "public_route_table" {
#   vpc_id = aws_vpc.my_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.my_igw.id
#   }

#   tags = {
#     Name = "public-route-table"
#   }
# }

# # Associate route table with the subnet
# resource "aws_route_table_association" "public_subnet_assoc" {
#   subnet_id      = aws_subnet.public_subnet.id
#   route_table_id = aws_route_table.public_route_table.id
# }

# # Output the VPC ID and subnet ID
# output "vpc_id" {
#   value = aws_vpc.my_vpc.id
# }

# output "public_subnet_id" {
#   value = aws_subnet.public_subnet.id
# }