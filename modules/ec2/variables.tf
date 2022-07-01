variable "instance_name" {
  description = "Name of EC2 instance"
  type        = string
}

variable "instance_username" {
  description = "Username"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "security_group_ids" {
  description = "Security group ID"
  type        = list(string)
}