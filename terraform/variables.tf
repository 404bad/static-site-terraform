variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for the static site"
  type        = string
}

variable "project_name" {
  description = "Project tag applied to all resources"
  type        = string
  default     = "static-site"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "site_dir" {
  description = "Local path to the site folder containing HTML/CSS files"
  type        = string
  default     = "../site"
}
