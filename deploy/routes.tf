# public route table
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.env}-public-routes",
    Environment = "${var.env}"
  }
}

# public route table -> internet gateway -> world
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  gateway_id             = "${aws_internet_gateway.main.id}"
  destination_cidr_block = "0.0.0.0/0"
}

# associates the public subnets with public route table
resource "aws_route_table_association" "public" {
  count = "${length(var.availability_zones)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# application route table
resource "aws_route_table" "application" {
  count = "${length(var.availability_zones)}"

  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.env}-application-routes - ${element(var.availability_zones, count.index)}",
    Environment = "${var.env}"
  }
}

# application route table -> nat gateway -> world
resource "aws_route" "application_gateway" {
  count = "${length(var.availability_zones)}"

  route_table_id         = "${element(aws_route_table.application.*.id, count.index)}"
  nat_gateway_id         = "${element(aws_nat_gateway.main.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
}

# associates the application subnets with application route table
resource "aws_route_table_association" "application" {
  count = "${length(var.availability_zones)}"

  subnet_id      = "${element(aws_subnet.application.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.application.*.id, count.index)}"
}

# database route table
resource "aws_route_table" "database" {
  count = "${length(var.availability_zones)}"

  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.env}-database-routes - ${element(var.availability_zones, count.index)}",
    Environment = "${var.env}"
  }
}

# database route table -> nat gateway -> world
resource "aws_route" "database_gateway" {
  count = "${length(var.availability_zones)}"

  route_table_id         = "${element(aws_route_table.database.*.id, count.index)}"
  nat_gateway_id         = "${element(aws_nat_gateway.main.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
}

# associates the database subnets with database route table
resource "aws_route_table_association" "database" {
  count = "${length(var.availability_zones)}"

  subnet_id      = "${element(aws_subnet.database.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.database.*.id, count.index)}"
}
