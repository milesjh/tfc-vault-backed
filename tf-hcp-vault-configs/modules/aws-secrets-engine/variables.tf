variable "email_address" {
  type        = string
  description = "Email address of the user. Will be appended to the IAM user name."
  default     = ""
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID to be used for Vault IAM Users"
  default     = "710320297709"
}

variable "region" {}