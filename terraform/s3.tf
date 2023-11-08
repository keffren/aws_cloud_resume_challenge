resource "aws_s3_bucket" "static_website" {
  bucket = "mateodev.cloud"

  tags = {
    Name = "resume-challenge-website"
    Project = "aws-cloud-resume-challenge"
    Terraform = "true"
  }
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "enable_static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }
}   

# Edit Block Public Access settings
resource "aws_s3_bucket_public_access_block" "allow_public_access" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Add a bucket policy that makes your bucket content publicly available
resource "aws_s3_bucket_policy" "allow_public_access" {
    bucket = aws_s3_bucket.static_website.id
    policy = <<-EOF
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "PublicReadGetObject",
                    "Effect": "Allow",
                    "Principal": "*",
                    "Action": [
                        "s3:GetObject"
                    ],
                    "Resource": [
                        "${aws_s3_bucket.static_website.arn}/*"
                    ]
                }
            ]
        }
    EOF

    depends_on = [ aws_s3_bucket_public_access_block.allow_public_access]
}
