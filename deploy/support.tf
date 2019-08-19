/*
 Optional support EC2 instance that can be created to debug connection issues 
 from within the application subnet. It also provides basic example for deploying
 EC2 instance should a non-serverless option be needed.
 */

# security group associated with EC2 instance to allow SSH access from bastion
resource "aws_security_group" "support" {
  count = "${var.debug ? 1 : 0}"

  name   = "${var.env}-support"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    description     = "allow SSH from bastion"
    protocol        = "tcp"
    from_port       = "22"
    to_port         = "22"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  egress {
    description = "allow all outbound"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-support",
    Environment = "${var.env}"
  }
}

# ec2 instance when var.debug=true
resource "aws_instance" "support" {
  count = "${var.debug ? 1 : 0}"

  ami                    = "${var.bastion_ami}"
  instance_type          = "${var.bastion_type}"
  key_name               = "${var.bastion_key}"
  subnet_id              = "${aws_subnet.application.0.id}"
  vpc_security_group_ids = ["${aws_security_group.support.0.id}"]

  tags = {
    Name        = "${var.env}-support",
    Environment = "${var.env}"
  }
}

/* TODO
 - put private key in bastion's /home/ec2-user/.ssh/id_rsa for easier ssh to other hosts
 - amazon-linux-extras install postgresql10
*/
