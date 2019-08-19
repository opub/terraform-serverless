# any values that the Serverless deployment requires are "shared" via the SSM Parameter Store

resource "aws_ssm_parameter" "vpc" {
  name        = "/${var.env}/vpc"
  description = "Main VPC for ${var.env}"
  type        = "String"
  value       = "${aws_vpc.main.id}"
}

resource "aws_ssm_parameter" "application_subnets" {
  name        = "/${var.env}/application/subnets"
  description = "Subnets that ${var.env} application will be deployed"
  type        = "StringList"
  value       = "${join(", ", aws_subnet.application.*.id)}"
}

resource "aws_ssm_parameter" "application_security_group" {
  name        = "/${var.env}/application/security_group"
  description = "Security Group for the ${var.env} application"
  type        = "String"
  value       = "${aws_security_group.application.id}"
}

resource "aws_ssm_parameter" "database_endpoint" {
  name        = "/${var.env}/database/endpoint"
  description = "Endpoint to connect to the ${var.env} database"
  type        = "String"
  value       = "${aws_rds_cluster.postgresql.endpoint}"
}

resource "aws_ssm_parameter" "database_port" {
  name        = "/${var.env}/database/port"
  description = "Port of the ${var.env} database"
  type        = "String"
  value       = "${aws_rds_cluster.postgresql.port}"
}

resource "aws_ssm_parameter" "database_name" {
  name        = "/${var.env}/database/name"
  description = "Name of the ${var.env} database"
  type        = "SecureString"
  value       = "${aws_rds_cluster.postgresql.database_name}"
}

resource "aws_ssm_parameter" "database_username" {
  name        = "/${var.env}/database/username"
  description = "Username to connect to the ${var.env} database"
  type        = "SecureString"
  value       = "${aws_rds_cluster.postgresql.master_username}"
}

resource "aws_ssm_parameter" "database_password" {
  name        = "/${var.env}/database/password"
  description = "Password to connect to the ${var.env} database"
  type        = "SecureString"
  value       = "${random_string.password.result}"
}
