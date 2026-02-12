variable "vpc_name" {
  type    = string
  default = "main-vpc"
}

variable "vpc_cidr" {
  type = string
}


variable "subnet_cidr_config" {
  type = map(any)
}