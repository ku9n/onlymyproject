variable "aws_access_key" {
  default = "xxxxxxxxxxxx"
}
variable "aws_secret_key" {
  default = "yyyyyyyyyyyy"
}
variable "region" {
  default = "eu-central-1"
}
variable "availability_zone1" {
    description = "Avaialbility Zones"
    default = "eu-central-1a"
}
variable "availability_zone2" {
    description = "Avaialbility Zones"
    default = "eu-central-1b"
}
variable "main_vpc_cidr" {
    description = "CIDR of the VPC"
    default = "10.0.0.0/16"
}
variable "quantity" {
 default = 2
}
 variable "public_key_path" {
  default = "/home/ku9n/.ssh/awsku9n.pem"
}
 variable "key_name" {
 default = "my_aws"
}
variable "amis" {
 default = {
 eu-central-1 = "ami-0b418580298265d5c"
 }
}
variable "aws_vpc" { # default vpc_id
  default = "vpc-ffdb1b95"
}
