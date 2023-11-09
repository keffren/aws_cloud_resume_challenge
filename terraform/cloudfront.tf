locals {
    s3_origin_id = "static-resume-site-distribution"
}

resource "aws_cloudfront_distribution" "s3_distribution" {

    origin {
        domain_name              = aws_s3_bucket.static_website.bucket_domain_name
        origin_id                = local.s3_origin_id
    }

    enabled             = true
    comment             = "enable HTTPS"
    default_root_object = "index.html"

    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = local.s3_origin_id

        forwarded_values {
            # CloudFront can cache different versions of your content based on the values of query string parameters
            query_string = false

            # Specify whether you want CloudFront to forward cookies to your origin server and, if so, which ones
            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "allow-all"
    }

    restrictions {
        geo_restriction {
            restriction_type = "whitelist"
            locations        = ["GB", "ES"]
        }
    }

    # The SSL configuration for this distribution (maximum one)
    viewer_certificate {
        cloudfront_default_certificate = true
    }

    tags = {
        Name = "resume-cloudfront-distribution"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}