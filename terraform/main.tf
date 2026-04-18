# S3 Bucket
resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
  tags   = local.common_tags
}

# Disable Block Public Access
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Static Website Hosting Configuration
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"   # Served when visiting the root URL /
  }

  error_document {
    key = "error.html"      # Served on 404 / any error
  }
}

#  Bucket Policy — Allow Public Read
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  # depends_on ensures the public access block is removed BEFORE the policy
  # is applied. Without this, AWS rejects the public policy while block is on.
  depends_on = [aws_s3_bucket_public_access_block.site]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"             # Anyone
        Action    = "s3:GetObject"  # Can only read — not write or delete
        Resource  = "${aws_s3_bucket.site.arn}/*"  # All objects in bucket
      }
    ]
  })
}

# Upload Site Files 
resource "aws_s3_object" "site_files" {
  for_each = fileset(var.site_dir, "**/*")

  bucket = aws_s3_bucket.site.id
  key    = each.value                          # File path becomes the S3 key (object name)
  source = "${var.site_dir}/${each.value}"     # Local file path

  content_type = lookup(
    local.mime_types,
    reverse(split(".", each.value))[0],
    "application/octet-stream"
  )
  etag = filemd5("${var.site_dir}/${each.value}")

  tags = local.common_tags
}
