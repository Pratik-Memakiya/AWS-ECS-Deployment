
variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "app_name" {
  type    = string
  default = "hello-ecs"
}
variable "image_tag" {
  type    = string
  default = "v1"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}
variable "acm_certificate_arn" {
  type    = string
  default = null
}
variable "secrets_manager_arn" {
  type    = string
  default = null
}
