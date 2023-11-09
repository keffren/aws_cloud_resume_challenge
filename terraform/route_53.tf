# PUBLIC Hosted Zone
resource "aws_route53_zone" "public_hz" {
    name = "mateodev.cloud"

    tags = {
        Name = "resume-challenge-public-hz"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

#Create Records: custom domains -> CloudFron endpoint
resource "aws_route53_record" "mateodev_domain" {
    zone_id = aws_route53_zone.public_hz.id
    name    = "mateodev.cloud"
    type    = "A"

    alias {
      name = aws_cloudfront_distribution.s3_distribution.domain_name
      zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
      evaluate_target_health = false
    }
}
