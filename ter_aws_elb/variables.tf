variable "aws_access_key" {
  default = "xxxxxxxxxxxxxx"
}

variable "aws_secret_key" {
  default = "yyyyyyyyyyyyyyyyyyy"
}
variable "region" {
  default = "eu-central-1"
}
variable "aws_vpc" { # default vpc_id
  default = "vpc-ffdb1b95"
}
variable "quantity" {
 default = 1
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
