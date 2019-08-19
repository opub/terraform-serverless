# public subnet for each availability zone 
resource "aws_subnet" "public" {
  count = "${length(var.availability_zones)}"

  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(var.cidr_block, 8, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.env}-public-subnet - ${element(var.availability_zones, count.index)}",
    Environment = "${var.env}"
  }
}

# application subnet for each availability zone 
resource "aws_subnet" "application" {
  count = "${length(var.availability_zones)}"

  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(var.cidr_block, 8, count.index + length(var.availability_zones))}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.env}-application-subnet - ${element(var.availability_zones, count.index)}",
    Environment = "${var.env}"
  }
}

# database subnet for each availability zone 
resource "aws_subnet" "database" {
  count = "${length(var.availability_zones)}"

  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(var.cidr_block, 8, count.index + length(var.availability_zones) * 2)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.env}-database-subnet - ${element(var.availability_zones, count.index)}",
    Environment = "${var.env}"
  }
}

# elastic IPs for the NAT gateways
resource "aws_eip" "nat" {
  count = "${length(var.availability_zones)}"
  vpc   = true

  tags = {
    Name        = "${var.env}-nat-eip - ${element(var.availability_zones, count.index)}",
    Environment = "${var.env}"
  }
}

# public NAT gateways
resource "aws_nat_gateway" "main" {
  count         = "${length(var.availability_zones)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"

  tags = {
    Name        = "${var.env}-nat-gateway - ${element(var.availability_zones, count.index)}",
    Environment = "${var.env}"
  }
}
