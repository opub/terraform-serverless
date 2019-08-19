# general
variable "profile" {
  description = "Name of profile for running Terraform"
  default     = "default"
}

variable "env" {
  description = "Target environment. Will be used in name prefixes."
  type        = "string"
  default     = "dev"
}

# network
variable "region" {
  description = "Target region"
  type        = "string"
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "Target availability zones (one or more). Must be within the region above."
  type        = "list"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cidr_block" {
  description = "Complete CIDR block for VPC"
  type        = "string"
  default     = "10.0.0.0/16"
}

# database
variable "db_name" {
  description = "Database name"
  type        = "string"
}

variable "db_port" {
  description = "Database port"
  default     = 5432
}

variable "db_username" {
  description = "Database master username"
  type        = "string"
}

resource "random_string" "password" {
  length  = 64
  special = false
}

# bastion
variable "bastion_ami" {
  description = "AMI to use for Bastion instance"
  type        = "string"
}

variable "bastion_type" {
  description = "EC2 type for Bastion instance"
  type        = "string"
  default     = "t2.micro"
}

variable "bastion_key" {
  description = "Key to use for Bastion instance"
  type        = "string"
}

variable "debug" {
  description = "Flag to enable debug resources"
  default     = false
}
