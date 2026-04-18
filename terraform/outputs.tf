output "website_url" {
  description = "Public URL of the S3 static website"
  value       = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.site.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.site.arn
}

output "files_uploaded" {
  description = "List of files uploaded to S3"
  value       = keys(aws_s3_object.site_files)
}
