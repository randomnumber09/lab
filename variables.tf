# variables.tf
variable "AWS_ACCESS_KEY_ID" {
  default = "string"
}
variable "AWS_SECRET_ACCESS_KEY" {
  default = "string"
}
variable "region" {
  default = "us-east-1"
}
variable "DB_USER" {
  default = "string"
}
variable "DB_PASSWORD" {
  default = "string"
}
variable "ingressCIDRblock" {
  type    = list
  default = ["0.0.0.0/0"]
}
# end of variables.tf
