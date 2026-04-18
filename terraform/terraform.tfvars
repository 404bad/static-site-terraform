# terraform.tfvars
# Actual values for variables — edit this file before applying.
# Add this file to .gitignore if it contains secrets (it doesn't here,
# but it's a good habit — tfvars files sometimes contain DB passwords etc.)

aws_region   = "us-east-1"
bucket_name  = "kailash-portfolio-2025"   # CHANGE THIS — must be globally unique
project_name = "static-site"
environment  = "prod"
site_dir     = "../site"
