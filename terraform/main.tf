# ── S3 Bucket ────────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
  tags   = local.common_tags
}

# ── Disable Block Public Access ───────────────────────────────────────────────
# By default, S3 blocks all public access. For a static website, we need
# objects to be publicly readable. We unblock it here, then add a bucket
# policy below that allows only s3:GetObject (read-only, not write).
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ── Static Website Hosting Configuration ─────────────────────────────────────
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"   # Served when visiting the root URL /
  }

  error_document {
    key = "error.html"      # Served on 404 / any error
  }
}

# ── Bucket Policy — Allow Public Read ─────────────────────────────────────────
# Allows anyone on the internet to GET (download/view) objects in this bucket.
# Does NOT allow PUT, DELETE, or any write operation — read-only.
# This depends on public access block being disabled first.
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

# ── Upload Site Files ─────────────────────────────────────────────────────────
# fileset() scans var.site_dir and returns a set of all file paths.
# for_each iterates over every file and creates one aws_s3_object per file.
# This means adding a new file to the site/ folder and re-applying
# automatically uploads it — no manual sync needed.
resource "aws_s3_object" "site_files" {
  for_each = fileset(var.site_dir, "**/*")

  bucket = aws_s3_bucket.site.id
  key    = each.value                          # File path becomes the S3 key (object name)
  source = "${var.site_dir}/${each.value}"     # Local file path

  # Set correct Content-Type based on file extension.
  # split(".") splits "style.css" → ["style", "css"]
  # reverse() → ["css", "style"]
  # [0] grabs "css"
  # lookup() checks the mime_types map — defaults to "application/octet-stream"
  content_type = lookup(
    local.mime_types,
    reverse(split(".", each.value))[0],
    "application/octet-stream"
  )

  # ETag-based change detection — Terraform re-uploads a file only if its
  # content has changed (MD5 hash mismatch). Efficient — no unnecessary uploads.
  etag = filemd5("${var.site_dir}/${each.value}")

  tags = local.common_tags
}
