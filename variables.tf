variable "pub_key" {
  description = "Name and or path to your public key for SSH"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_key_name" {
  description = "The name you want to give to your ssh public key"
  default = "key"
}

variable "instance_type" {
  description = "The type of your EC2 instance e.g t2.large"
  default     = "t2.medium"
}

variable "aws_region_name" {
  description = "The region where your EC2 instance will be created in e.g us-east-1"
  default = "us-east-2"
}
