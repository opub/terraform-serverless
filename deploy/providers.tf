provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
  version = ">= 2.23.0"
}

provider "random" {
  version = "~> 2.2"
}

terraform {
  required_version = ">= 0.12.0"
}
