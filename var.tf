variable "vpc_cidr" {
    type    = string
    default = "10.1.0.0/16"  # Changed to a different CIDR block
}

variable "subnet_cidr" {
    type    = string
    default = "10.1.1.0/24"  # Changed to a different CIDR block
}

variable "availability_zone" {
    type    = string
    default = "us-east-2a"  # Changed availability zone to us-east-2
}

variable "environment_prefix" {
    type    = string
    default = "test"  # Changed environment prefix to test
}

variable "instance_size" {
    type    = string
    default = "t2.small"  # Changed instance type to t2.small
}

variable "ssh_key_path" {
    type    = string
    default = "path/to/your/new_key"  # Updated path to reflect a new key
}
