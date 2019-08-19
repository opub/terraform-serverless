# main vpc that all resources will belong to
resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.env}-vpc",
    Environment = "${var.env}"
  }
}

# internet gateway for public subnets
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.env}-internet-gateway",
    Environment = "${var.env}"
  }
}
