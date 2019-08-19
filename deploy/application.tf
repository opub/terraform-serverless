# security group that application Lambda functions and EC2 instances will belong to 
resource "aws_security_group" "application" {
  name   = "${var.env}-application"
  vpc_id = "${aws_vpc.main.id}"

  egress {
    description = "allow SQL outbound to database"
    protocol    = "tcp"
    from_port   = "${var.db_port}"
    to_port     = "${var.db_port}"
    cidr_blocks = "${aws_subnet.database.*.cidr_block}"
  }

  egress {
    description = "allow HTTPS outbound for public AWS managed services"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-application",
    Environment = "${var.env}"
  }
}

# these VPC endpoints are needed to allow access to public SSM service

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = "${aws_vpc.main.id}"
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = "${aws_subnet.application.*.id}"

  security_group_ids = [
    "${aws_security_group.application.id}",
  ]

  tags = {
    Name        = "${var.env}-vpc-endpoint-ssm",
    Environment = "${var.env}"
  }
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = "${aws_vpc.main.id}"
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = "${aws_subnet.application.*.id}"

  security_group_ids = [
    "${aws_security_group.application.id}",
  ]

  tags = {
    Name        = "${var.env}-vpc-endpoint-ec2",
    Environment = "${var.env}"
  }
}
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = "${aws_vpc.main.id}"
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = "${aws_subnet.application.*.id}"

  security_group_ids = [
    "${aws_security_group.application.id}",
  ]

  tags = {
    Name        = "${var.env}-vpc-endpoint-ec2messages",
    Environment = "${var.env}"
  }
}
