output "website_endpoint" {
    value = aws_s3_bucket_website_configuration.enable_static_website.website_endpoint
}
