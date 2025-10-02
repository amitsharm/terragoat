
data "aws_caller_identity" "current" {}

variable "company_name" {
  default = "workshop"
}

variable "environment" {
  default = "dev"
}

locals {
  resource_prefix = {
    value = "${data.aws_caller_identity.current.account_id}-${var.company_name}-${var.environment}"
  }
}



variable "profile" {
  default = "default"
}

variable "region" {
  default = "us-east-1"
}


variable "dbname" {
  type = string
  description = "Name of the Database"
  default     = "db1"
}

variable "password" {
  type = string
  description = "Database password"
  default     = "Aa1234321Bb"
}

variable "neptune-dbname" {
  type = string
  description = "Name of the Neptune graph database"
  default     = "neptunedb1"
}