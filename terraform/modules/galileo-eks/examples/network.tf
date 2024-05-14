resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "galileo_${var.environment}_vpc"
  }
}

# Create Public Subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.0.0/19"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true # Enable auto-assign public IP

  tags = {
    Name = "galileo_${var.environment}_public_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.32.0/19"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "galileo_${var.environment}_public_subnet_b"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.64.0/19"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "galileo_${var.environment}_public_subnet_c"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.96.0/19"
  availability_zone = "us-west-2a"

  tags = {
    Name = "galileo_${var.environment}_private_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.128.0/19"
  availability_zone = "us-west-2b"

  tags = {
    Name = "galileo_${var.environment}_private_subnet_b"
  }
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.160.0/19"
  availability_zone = "us-west-2c"

  tags = {
    Name = "galileo_${var.environment}_private_subnet_c"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "galileo_${var.environment}_igw"
  }
}

# Elastic IP for NAT Gateway in Subnet A
resource "aws_eip" "nat_eip_a" {
  domain = "vpc"
}

# NAT Gateway in Public Subnet A
resource "aws_nat_gateway" "nat_gw_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "galileo_${var.environment}_nat_gw_a"
  }
}

# Elastic IP for NAT Gateway in Subnet B
resource "aws_eip" "nat_eip_b" {
  domain = "vpc"
}

# NAT Gateway in Public Subnet B
resource "aws_nat_gateway" "nat_gw_b" {
  allocation_id = aws_eip.nat_eip_b.id
  subnet_id     = aws_subnet.public_subnet_b.id

  tags = {
    Name = "galileo_${var.environment}_nat_gw_b"
  }
}

# Elastic IP for NAT Gateway in Subnet C
resource "aws_eip" "nat_eip_c" {
  domain = "vpc"
}

# NAT Gateway in Public Subnet C
resource "aws_nat_gateway" "nat_gw_c" {
  allocation_id = aws_eip.nat_eip_c.id
  subnet_id     = aws_subnet.public_subnet_c.id

  tags = {
    Name = "galileo_${var.environment}_nat_gw_c"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "galileo_${var.environment}_public_rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_rta_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_c" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Tables

# Private Route Table for Subnet A
resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_a.id
  }

  tags = {
    Name = "galileo_${var.environment}_private_rt_a"
  }
}

# Associate Private Subnet A with Private Route Table A
resource "aws_route_table_association" "private_rta_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt_a.id
}

# Private Route Table for Subnet B
resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_b.id
  }

  tags = {
    Name = "galileo_${var.environment}_private_rt_b"
  }
}

# Associate Private Subnet B with Private Route Table B
resource "aws_route_table_association" "private_rta_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt_b.id
}

# Private Route Table for Subnet C
resource "aws_route_table" "private_rt_c" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_c.id
  }

  tags = {
    Name = "galileo_${var.environment}_private_rt_c"
  }
}

# Associate Private Subnet C with Private Route Table C
resource "aws_route_table_association" "private_rta_c" {
  subnet_id      = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.private_rt_c.id
}
