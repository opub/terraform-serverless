# associates database sybnets with a group
resource "aws_db_subnet_group" "default" {
  name       = "${var.env}-database-subnet-group"
  subnet_ids = "${aws_subnet.database.*.id}"

  tags = {
    Name        = "${var.env}-database-subnet-group",
    Environment = "${var.env}"
  }
}

# database's security group that only allows SQL access from application subnet
resource "aws_security_group" "database" {
  name   = "${var.env}-database"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    description = "allow SQL inbound from application"
    protocol    = "tcp"
    from_port   = "${var.db_port}"
    to_port     = "${var.db_port}"
    cidr_blocks = "${aws_subnet.application.*.cidr_block}"
  }

  tags = {
    Name        = "${var.env}-database",
    Environment = "${var.env}"
  }
}

# serverless aurora postgresql database cluster
resource "aws_rds_cluster" "postgresql" {
  cluster_identifier = "${var.env}-postgresql"

  engine          = "aurora-postgresql"
  engine_version  = "10.7"
  engine_mode     = "serverless"
  port            = "${var.db_port}"
  database_name   = "${var.db_name}"
  master_username = "${var.db_username}"
  master_password = "${random_string.password.result}"

  backup_retention_period = 7
  preferred_backup_window = "02:00-03:00"
  apply_immediately       = true
  skip_final_snapshot     = true

  vpc_security_group_ids          = ["${aws_security_group.database.id}"]
  db_subnet_group_name            = "${aws_db_subnet_group.default.id}"
  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.default.id}"

  tags = {
    Name        = "${var.env}-postgresql",
    Environment = "${var.env}"
  }
}

resource "aws_rds_cluster_parameter_group" "default" {
  name   = "${var.env}-aurora-postgresql-cluster-params"
  family = "aurora-postgresql10"
}
