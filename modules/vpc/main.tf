# Define the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = { Name = var.vpc_name }
}

# Internet Gateway for Public Access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

# Create 4 Subnets
resource "aws_subnet" "subnets" {
  for_each                = var.subnet_cidr_config
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public
  tags                    = { Name = each.key }
}

# NAT Gateway Setup (Required for Private Subnets)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnets["subnet-pub"].id # Must be in public subnet
  tags          = { Name = "main-nat-gw" }
}

# Public Route Table (subnet-pub)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Private Route Table (subnet-priv*)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}

# 6. Route Table Associations
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.subnets["subnet-pub"].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = toset(["subnet-priv1", "subnet-priv2", "subnet-priv3"])
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.private.id
}

# Security Groups
# Public SG: Allows SSH from anywhere
resource "aws_security_group" "public_ssh_sg" {
  name   = "public-ssh-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private SG: Allows SSH ONLY from subnet-pub
resource "aws_security_group" "private_ssh_sg" {
  name   = "private-ssh-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ssh_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Public subnet NACL
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [
    aws_subnet.subnets["subnet-pub"].id
  ]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "nacl_public_subnet"
  }
}


# Private subnet NACL
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [
    aws_subnet.subnets["subnet-priv1"].id,
    aws_subnet.subnets["subnet-priv2"].id,
    aws_subnet.subnets["subnet-priv3"].id,
  ]
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_subnet.subnets["subnet-pub"].cidr_block
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "nacl_private_subnet"
  }
}