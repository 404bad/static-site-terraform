locals {
  # Common tags applied to every resource — makes billing and filtering easy
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # MIME type map — tells S3 the correct Content-Type for each file extension.
  # Without this, S3 serves everything as binary/octet-stream and browsers
  # download the files instead of rendering them.
  mime_types = {
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "json" = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
    "txt"  = "text/plain"
    "pdf"  = "application/pdf"
    "woff"  = "font/woff"
    "woff2" = "font/woff2"
  }
}
