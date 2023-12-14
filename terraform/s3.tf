######################################  TERRAFORM BACK-END BUCKET
resource "aws_s3_bucket" "resume_challenge_tf" {
  bucket = "resume-challenge-terraform"

  tags = {
    Name = "resume-challenge-terraform"
    Project = "aws-cloud-resume-challenge"
    Terraform = "true"
  }
}


resource "aws_s3_bucket_versioning" "resume_challenge_tf" {
  bucket = aws_s3_bucket.resume_challenge_tf.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Disable Public Access
resource "aws_s3_bucket_public_access_block" "resume_challenge_tf" {
  bucket = aws_s3_bucket.resume_challenge_tf.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

######################################  STATIC WEBSITE BUCKET
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

######################################  STATIC WEBSITE BUCKET SERVER ACCESS LOGS
resource "aws_s3_bucket" "static_website_logs" {
  bucket = "mateodev.cloud-server-access-logs"

  tags = {
    Name = "mateodev.cloud-server-access-logs"
    Project = "aws-cloud-resume-challenge"
    Terraform = "true"
  }
}

# Disable Public Access
resource "aws_s3_bucket_public_access_block" "static_website_logs" {
  bucket = aws_s3_bucket.static_website_logs.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Enabling mateo.dev  bucket server access logs
resource "aws_s3_bucket_logging" "static_website_logs" {
  bucket = aws_s3_bucket.static_website.id

  target_bucket = aws_s3_bucket.static_website_logs.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "static_website_logs" {
  bucket = aws_s3_bucket.static_website_logs.id

  rule {
    id = "1-day-ttl"

    filter {
      prefix = "log"
    }

    expiration {
      days = 1
    }

    status = "Enabled"
  }
}

###################################### CODEPIPELINE BUCKET
resource "aws_s3_bucket" "backend_pipeline_bucket" {
  bucket = "resume-challenge-backend-pipeline"

  tags = {
    Name = "CodePipeLine-bucket"
    Project = "aws-cloud-resume-challenge"
    Terraform = "true"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backend_pipeline_lifecycle" {
  bucket = aws_s3_bucket.backend_pipeline_bucket.id

  rule {
    id = "1-day-ttl"

    filter {
      prefix = "source_output"
    }

    expiration {
      days = 1
    }

    status = "Enabled"
  }
}