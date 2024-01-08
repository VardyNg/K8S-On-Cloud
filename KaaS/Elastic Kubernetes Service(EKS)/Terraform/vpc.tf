resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_subnet" "main" {
  count = length(var.subnet_az_list)

  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = element(var.subnet_az_list, count.index)
  tags = {
    Name = "${var.cluster_name}-default-subnet-${element(var.subnet_az_list, count.index)}"
  }
}