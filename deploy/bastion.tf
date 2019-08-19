# bastion host that can be used as a jump server for working with the stack post deployment
resource "aws_launch_configuration" "bastion" {
  name = "${var.env}-bastion"

  image_id                    = "${var.bastion_ami}"
  instance_type               = "${var.bastion_type}"
  key_name                    = "${var.bastion_key}"
  associate_public_ip_address = true
  enable_monitoring           = false
  security_groups             = ["${aws_security_group.bastion.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

# ASG makes it automatically restart if it crashes or an AZ goes down
resource "aws_autoscaling_group" "bastion" {
  name = "${var.env}-bastion-asg"

  min_size             = 0
  desired_capacity     = 1
  max_size             = 1
  health_check_type    = "EC2"
  launch_configuration = "${aws_launch_configuration.bastion.name}"
  vpc_zone_identifier  = "${aws_subnet.public.*.id}"

  tags = [
    {
      key                 = "Name"
      value               = "${var.env}-bastion"
      propagate_at_launch = true
      }, {
      key                 = "Environment"
      value               = "${var.env}"
      propagate_at_launch = true
    }
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# bastion's security group to allow SSH access
resource "aws_security_group" "bastion" {
  name   = "${var.env}-bastion"
  vpc_id = "${aws_vpc.main.id}"

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "allow SSH inbound"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outbound"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-bastion",
    Environment = "${var.env}"
  }
}
