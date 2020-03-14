provider "aws" {
  region     = "${var.region}"
}

data "aws_availability_zones" "all" {}
data "aws_subnet_ids" "all" {
  vpc_id = var.aws_vpc
}

resource "aws_instance" "web" {
  ami               = "${lookup(var.amis,var.region)}"
  count             = "${var.quantity}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_profile.name}"
  source_dest_check = false
  instance_type = "t2.micro"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install apache2 -y
              sudo apt  install awscli -y
              aws configure
              "${var.aws_access_key}"
              "${var.aws_secret_key}"
              "${var.region}"
              json
              sudo aws s3 sync s3://s3-ku9nwebsite/ /var/www/html/
              EOF
  tags = {
    Name = "${format("web-%03d", count.index + 1)}"
  }
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_all"
  }
}
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "s3-ku9nwebsite"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
}
resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket = "${aws_s3_bucket.s3_bucket.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::s3-ku9nwebsite/*",
      "Condition": {
         "IpAddress": {"aws:SourceIp": "8.8.8.8/32"}
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role" "s3_role" {
  name = "s3_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "s3-value"
  }
}
resource "aws_iam_instance_profile" "s3_profile" {
  name = "s3_profile"
  role = "${aws_iam_role.s3_role.name}"
}
resource "aws_iam_role_policy" "s3_policy" {
  name = "s3_policy"
  role = "${aws_iam_role.s3_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_lb" "alb_tf" {
  name               = "lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allow_tls.id}"]
  subnets            = data.aws_subnet_ids.all.ids

  tags = {
    Environment = "production"
  }
}
resource "aws_lb_target_group" "lb_tg" {
  name     = "tf-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.aws_vpc

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = "80"
  }
}
resource "aws_lb_listener" "first_listener" {
  load_balancer_arn = "${aws_lb.alb_tf.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb_tg.arn}"
  }
}
resource "aws_lb_target_group_attachment" "my_atach1" {
  count = length(aws_instance.web)
  target_group_arn = "${aws_lb_target_group.lb_tg.arn}"
  target_id        = aws_instance.web[count.index].id
  port             = 80
}
resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync /home/ku9n/onlymyproject/portfolio/ s3://${aws_s3_bucket.s3_bucket.id}"
  }
}
