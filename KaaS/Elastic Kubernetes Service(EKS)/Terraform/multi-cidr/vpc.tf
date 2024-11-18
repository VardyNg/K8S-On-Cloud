module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

resource "aws_subnet" "additional" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = "10.0.51.0/24"
  availability_zone       = local.azs[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}-additional-subnet"
  }
}

resource "aws_route_table_association" "additional" {
  subnet_id      = aws_subnet.additional.id
  route_table_id = module.vpc.public_route_table_ids.0
}