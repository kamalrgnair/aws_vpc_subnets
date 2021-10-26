#====================================================================
#Fetching availability Zones
#====================================================================
data "aws_availability_zones" "az" {
  state = "available"
}
#====================================================================
# Vpc Creation
#====================================================================
resource "aws_vpc" "vpc" {
  cidr_block                  = var.vpc_cidr
  instance_tenancy            = "default"
  enable_dns_support          = true
  enable_dns_hostnames        = true
  tags = {
    Name        = "vpc"
    project     = "${var.project}-vpc"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}
#====================================================================
#Attaching Internet GateWay
#====================================================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-igw"
    project     = var.project
  }
  
  lifecycle {
    create_before_destroy = true
  }

}
#====================================================================
# Creating Public Subnet1
#====================================================================
resource "aws_subnet" "public1" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,0)
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.az.names[0]
  tags = {
    Name    = "${var.project}-public1"
    project = var.project
  }

 lifecycle {
    create_before_destroy = true
  }
  
}
#====================================================================
# Creating Public Subnet2
#====================================================================
resource "aws_subnet" "public2" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,1)
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.az.names[1]
  tags = {
    Name    = "${var.project}-public2"
    project = var.project
  }

  lifecycle {
    create_before_destroy = true
 }
  
}
#====================================================================
# Creating Public Subnet3
#====================================================================
resource "aws_subnet" "public3" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,2)
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.az.names[2]
  tags = {
    Name    = "${var.project}-public3"
    project = var.project
  }

  lifecycle {
    create_before_destroy = true
  }
  
}
#====================================================================
# Creating Private Subnet1
#====================================================================
resource "aws_subnet" "private1" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,3)
  map_public_ip_on_launch   = false
  availability_zone         = data.aws_availability_zones.az.names[0]
  tags = {
    Name    = "${var.project}-private1"
    project = var.project
  }

  lifecycle {
    create_before_destroy = true
  }
  
}
#====================================================================
# Creating Private Subnet2
#====================================================================
resource "aws_subnet" "private2" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,4)
  map_public_ip_on_launch   = false
  availability_zone         = data.aws_availability_zones.az.names[1]
  tags = {
    Name    = "${var.project}-private2"
    project = var.project
  }

  lifecycle {
    create_before_destroy = true
  }
  
}
#====================================================================
# Creating Private Subnet3
#====================================================================
resource "aws_subnet" "private3" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,5)
  map_public_ip_on_launch   = false
  availability_zone         = data.aws_availability_zones.az.names[2]
  tags = {
    Name    = "${var.project}-private3"
    project = var.project
  }

  lifecycle {
    create_before_destroy = true
  }
  
}
#====================================================================
# Creating Elastic Ip for NatGateWay
#====================================================================

resource "aws_eip" "eip" {
  vpc      = true
  tags = {
    Name = "${var.project}-eip"
    Project = var.project
  }
}
#====================================================================
#Nat GateWay Creation
#====================================================================
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name    = "${var.project}-nat"
    project = var.project
  }
}
#====================================================================
# Route Table Public
#====================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route{
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
 

  tags = {
    Name    = "${var.project}-public-rtb"
    project = var.project
  }
}
#====================================================================
# Route Table Private
#====================================================================
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
          cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.nat.id
    }
 
  tags = {
    Name    = "${var.project}-private-rtb"
    project = var.project
  }
}
#====================================================================
#Route Table association public route table
#====================================================================
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}
#====================================================================
# Route Table association Private route table
#====================================================================
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
#====================================================================

