provider "aws" {
  region     = "${var.region}"
}
data "aws_availability_zones" "all" {}
#VPC
resource "aws_vpc" "myHAvpc" {
  cidr_block       = "${var.main_vpc_cidr}"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "myHAvpc"
  }
}

 #Subnets
resource "aws_subnet" "subnet1" {
  vpc_id     = "${aws_vpc.myHAvpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.availability_zone1}"


  tags = {
    Name = "subnet-1"
    }
}


resource "aws_subnet" "subnet2" {
  vpc_id     = "${aws_vpc.myHAvpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.availability_zone2}"


  tags = {
    Name = "subnet-2"
  }
}
resource "aws_subnet" "subnet3" {
  vpc_id     = "${aws_vpc.myHAvpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.availability_zone1}"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnetelb-1"
  }
}
resource "aws_subnet" "subnet4" {
  vpc_id     = "${aws_vpc.myHAvpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "${var.availability_zone2}"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnetelb-2"
  }
}
resource "aws_subnet" "subnet5" {
  vpc_id     = "${aws_vpc.myHAvpc.id}"
  cidr_block = "10.0.5.0/24"
  availability_zone = "${var.availability_zone1}"


  tags = {
    Name = "subnetdb-1"
  }
}
resource "aws_subnet" "subnet6" {
  vpc_id     = "${aws_vpc.myHAvpc.id}"
  cidr_block = "10.0.6.0/24"
  availability_zone = "${var.availability_zone2}"


  tags = {
    Name = "subnetdb-2"
  }
}
resource "aws_subnet" "subnet7" {
  vpc_id     = "${aws_vpc.myHAvpc.id}"
  cidr_block = "10.0.7.0/24"
  availability_zone = "${var.availability_zone1}"


  tags = {
    Name = "subnet-1nat"
  }
}
resource "aws_subnet" "subnet8" {
  vpc_id     = "${aws_vpc.myHAvpc.id}"
  cidr_block = "10.0.8.0/24"
  availability_zone = "${var.availability_zone2}"


  tags = {
    Name = "subnet-2nat"
  }
}

#InternetGateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.myHAvpc.id}"

  tags = {
    Name = "igw"
  }
}

#NAT
resource "aws_eip" "nat" {
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.subnet8.id}"

  tags = {
    Name = "nat"
  }
}

#RouteTables

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.myHAvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.myHAvpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.natgw.id}"
  }

  tags = {
    Name = "private-rt"
  }
}

#PUBLIC Subnet to route table


resource "aws_route_table_association" "public-association-1" {
  subnet_id      = "${aws_subnet.subnet3.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}


resource "aws_route_table_association" "public-association-2" {
  subnet_id      = "${aws_subnet.subnet4.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}


resource "aws_route_table_association" "public-association-3" {
  subnet_id      = "${aws_subnet.subnet7.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}


resource "aws_route_table_association" "public-association-4" {
  subnet_id      = "${aws_subnet.subnet8.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}



#PRIVATE Subnets to route table
resource "aws_route_table_association" "private-association-1" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}


resource "aws_route_table_association" "private-association-2" {
  subnet_id      = "${aws_subnet.subnet2.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}


resource "aws_route_table_association" "private-association-3" {
  subnet_id      = "${aws_subnet.subnet5.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}


resource "aws_route_table_association" "private-association-4" {
  subnet_id      = "${aws_subnet.subnet6.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

#AWS-USER
#resource "aws_iam_user" "s3" {
#  name = "s3-read"
#  path = "/"
#
#  tags = {
#    tag-key = "s3-user"
#  }
#}
#
#resource "aws_iam_access_key" "lb" {
#  user = "${aws_iam_user.s3.name}"
#}
#
#resource "aws_iam_user_policy" "s3_readonly" {
#  name = "pol_s3"
#  user = "${aws_iam_user.s3.name}"
#
#  policy = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Effect": "Allow",
#            "Action": [
#                "s3:Get*",
#                "s3:List*"
#            ],
#            "Resource": "*"
#        }
#    ]
#}
#EOF
#}
#
#AWS-ROLE
#resource "aws_iam_instance_profile" "s3_profile" {
#  name = "s3_profile"
#  role = "${aws_iam_role.s3role.name}"
#}
#
#resource "aws_iam_role" "s3role" {
#  name = "s3_role"
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Action": [
#        "s3:Get*",
#        "s3:List*"
#        "sts:AssumeRole"
#      ],
#      "Resource": "${var.s3_bucket}"
#    }
#  ]
#}
#EOF
#
#  tags = {
#    tag-key = "s3-value"
#  }
#}
#AWS-AS-POLICY
resource "aws_autoscaling_policy" "asg-policy-1" {
  name                   = "asg-policy"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
resource "aws_autoscaling_group" "asg" {
  name = "asg"
  launch_configuration = "${aws_launch_configuration.lc.id}"
  vpc_zone_identifier = ["${aws_subnet.subnet3.id}", "${aws_subnet.subnet4.id}"]
  min_size = 2
  max_size = 10

  load_balancers = ["${aws_elb.elb.name}"]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "ASG"
    propagate_at_launch = true
  }
}
resource "aws_launch_configuration" "lc" {
  name = "lc"
  image_id = "${lookup(var.amis,var.region)}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.lc-sg.id}"]

#  iam_instance_profile = "${aws_iam_instance_profile.s3_profile.name}"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 mysql-server mysql-client php7.2 php7.2-dev -y
              sudo service apache2 start
              sudo mysql -u root -e "CREATE USER 'ku9n'@'localhost' IDENTIFIED BY 'password';"
              sudo mysql -u root -e "FLUSH PRIVILEGES;"
              sudo mysql -u root -e "CREATE DATABASE wordpressdb;"
              sudo service mysql start
              wget https://wordpress.org/latest.tar.gz
              tar -xvzf latest.tar.gz
              sudo cp -r wordpress/* /var/www/html
              sudo apt install php7.2-mysql
              sudo chown -R www-data:www-data /var/www/html
              cd /var/www/html/
              sudo rm index.html
              sudo systemctl restart apache2
              EOF
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_elb" "elb" {
  name = "elb"
  security_groups = ["${aws_security_group.elb-sg.id}"]
  subnets = ["${aws_subnet.subnet3.id}", "${aws_subnet.subnet4.id}"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "TCP:80"
    #target = "HTTP:80/"
  }

  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }
}

resource "aws_security_group" "lc-sg" {
  name = "lc-sg"
  vpc_id      = "${aws_vpc.myHAvpc.id}"
  # Inbound HTTP from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "elb-sg" {
  name = "elb-sg"
  vpc_id      = "${aws_vpc.myHAvpc.id}"
  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_subnet_group" "HA-DB" {
  name       = "db-group"
  subnet_ids = ["${aws_subnet.subnet5.id}", "${aws_subnet.subnet6.id}"]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "mydb" {
  allocated_storage        = 8 # gigabytes
  backup_retention_period  = 7   # in days
  db_subnet_group_name     = "${aws_db_subnet_group.HA-DB.name}"
  engine                   = "mysql"
  engine_version           = "5.7"
  identifier               = "mydb"
  instance_class           = "db.t2.micro"
  multi_az                 = false
  name                     = "mydb"
  password                 = "password"
  port                     = 3306
  storage_type             = "gp2"
  username                 = "ku9n"
  vpc_security_group_ids   = ["${aws_security_group.mydb_sec_group.id}"]
}
resource "aws_security_group" "mydb_sec_group" {
  name = "mydb"
  vpc_id = "${aws_vpc.myHAvpc.id}"

  # Only mysql in
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
