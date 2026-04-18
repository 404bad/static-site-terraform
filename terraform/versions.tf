terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ── Remote Backend ───────────────────────────────────────────────────────
  # State is stored in S3 and locked via DynamoDB.
  # The bucket "tf01" and table "dynamotfdb" must already exist before
  # running terraform init. Create them using the bootstrap/ config first.
  backend "s3" {
    bucket         = "tf01"
    key            = "static-site/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamotfdb"
    encrypt        = true
  }
}
