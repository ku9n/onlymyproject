variable "aws_access_key" {
  default = "AKIAJF5CA6AAX6GPPKRQ"
}

variable "aws_secret_key" {
  default = "92ayY68Z10uC8BYl3eqR2HCVYl/amxYWrpqE+aqx"
}
variable "region" {
  default = "eu-central-1"
}
variable "aws_vpc" { # default vpc_id
  default = "vpc-ffdb1b95"
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
