// Main VPC
resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr
	
  tags = {
    Name = "${local.name}-vpc"
  }
}

// secondary CIDR block
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.secondary_cidr_blocks
}

// Subnets in primarty CIDR block
resource "aws_subnet" "subnet_primary_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, 0)
  availability_zone = "${local.region}a"

  tags = {
    Name = "${local.name}-subnet-primary-1"
  }
}

resource "aws_subnet" "subnet_primary_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, 1)
  availability_zone = "${local.region}b"

  tags = {
    Name = "${local.name}-subnet-primary-2"
  }
}

resource "aws_subnet" "subnet_primary_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, 2)
  availability_zone = "${local.region}c"

  tags = {
    Name = "${local.name}-subnet-primary-3"
  }
}

// Subnets in secondary CIDR block
resource "aws_subnet" "subnet_secondary_1" {
	vpc_id     = aws_vpc.main.id
	cidr_block = cidrsubnet(local.secondary_cidr_blocks, 8, 0)
	availability_zone = "${local.region}a"

	tags = {
		Name = "${local.name}-subnet-secondary-1"
	}
}

resource "aws_subnet" "subnet_secondary_2" {
	vpc_id     = aws_vpc.main.id
	cidr_block = cidrsubnet(local.secondary_cidr_blocks, 8, 1)
	availability_zone = "${local.region}b"

	tags = {
		Name = "${local.name}-subnet-secondary-2"
	}
}

resource "aws_subnet" "subnet_secondary_3" {
	vpc_id     = aws_vpc.main.id
	cidr_block = cidrsubnet(local.secondary_cidr_blocks, 8, 2)
	availability_zone = "${local.region}c"

	tags = {
		Name = "${local.name}-subnet-secondary-3"
	}
}

// Public Subnet for the NAT Gateway
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, 4)

  tags = {
    Name = "${local.name}-public-subnet-1"
  }
}

// Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-igw"
  }
}

// NAT Gateway
resource "aws_eip" "nat" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "${local.name}-nat-gw"
  }
}

// Route Tables
resource "aws_route_table" "public_subnet_to_igw" {
  vpc_id = aws_vpc.main.id
	
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

	route {
		cidr_block = local.secondary_cidr_blocks
		gateway_id = "local"
	}

	route {
		cidr_block = local.secondary_cidr_blocks
		gateway_id = "local"
	}

	tags = {
		Name = "${local.name}-public-route-table"
	}
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnet_to_igw.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

	route {
		cidr_block = local.secondary_cidr_blocks
		gateway_id = "local"
	}
	
	tags = {
		Name = "${local.name}-private-route-table"
	}
}

resource "aws_route_table_association" "private_subnet_primary_1" {
	subnet_id      = aws_subnet.subnet_primary_1.id
	route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_primary_2" {
	subnet_id      = aws_subnet.subnet_primary_2.id
	route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_primary_3" {
	subnet_id      = aws_subnet.subnet_primary_3.id
	route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_secondary_1" {
	subnet_id      = aws_subnet.subnet_secondary_1.id
	route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_secondary_2" {
	subnet_id      = aws_subnet.subnet_secondary_2.id
	route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_secondary_3" {
	subnet_id      = aws_subnet.subnet_secondary_3.id
	route_table_id = aws_route_table.private_route_table.id
}