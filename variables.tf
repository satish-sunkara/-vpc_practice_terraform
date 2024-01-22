variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
  
}

variable "enable_dns_hostnames" {
    type = bool
    default = true
  
}

variable "common_tags" {
    type = map 
    default = {
        Project = "roboshop"
        Environment = "prod"
        Terraform = true
    }
  
}

variable "aws_vpc_tags" {
    default = {} 
}

variable "projectname" {
    default = {}
  
}

variable "environment" {
    default = {}
  
}

variable "igw_tags" {
    default = {}
  
}

variable "public-vpc-cidr" {
    type = list 
    validation {
        condition = length(var.public-vpc-cidr) == 2
        error_message = "Please provide only 2 public valid subnet CIDR"
    }
  
}

variable "public_subnet_tags" {
    default = {}
  
}

variable "private-vpc-cidr" {
    type = list 
    validation {
        condition = length(var.private-vpc-cidr) == 2
        error_message = "Please provide only 2 private valid subnet CIDR"
    }
  
}

variable "private_subnet_tags" {
    default = {}
  
}

variable "database-vpc-cidr" {
    type = list 
    validation {
        condition = length(var.database-vpc-cidr) == 2
        error_message = "Please provide only 2 database valid subnet CIDR"
    }
  
}

variable "database_subnet_tags" {
    default = {}
  
}

variable "nat_subnet_tags" {
    default = {}
}

variable "public_route_table_tags" {
    default = {}
  
}

variable "private_route_table_tags" {
    default = {}
  
}

variable "database_route_table_tags" {
    default = {}
  
}

variable "is_peering_required" {
    type = bool
    default = false
  
}

variable "acceptors_vpc_id" {
    default = "" 
}

variable "vpc_peering_connection_tags" {
  default = {}
}
