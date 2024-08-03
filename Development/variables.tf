variable "ami" {
  type        = string
  description = "ubuntu image"
}
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}
variable "key_name" {
  type = string
  description = "key name"
  
}