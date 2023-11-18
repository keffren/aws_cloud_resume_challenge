######################################  LAMBDA SERVICE ROLE
resource "aws_iam_role" "lambda_service" {
    name = "lambda-service"
  
    assume_role_policy = <<-EOF
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "lambda.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
    EOF

    tags = {
        Name = "lambda-service-role"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}


resource "aws_iam_policy" "lambda_permissions" {
    name        = "lambda-permissions"
    path        = "/"
    description = "Grant permissions to the lambda function "

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "logs:CreateLogGroup",
                "Resource": "arn:aws:logs:eu-west-1:${local.aws_account_number}:*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": [
                    "arn:aws:logs:eu-west-1:${local.aws_account_number}:log-group:/aws/lambda/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": "dynamoDB:*",
                "Resource": "arn:aws:dynamodb:eu-west-1:${local.aws_account_number}:table/resume-challenge-counter"
            }
        ]
    })

    tags = {
        Name = "lambda-policy"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

resource "aws_iam_role_policy_attachment" "lambda_service_role_attachment" {
    role = aws_iam_role.lambda_service.name
    policy_arn = aws_iam_policy.lambda_permissions.arn
}

######################################  Create role for CODEBUILD
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "custom_codebuild_service_role" {
    name               = "custom-codebuild-service-role"
    assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

    tags = {
        Name = "custom-codebuild-service-role"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

data "aws_iam_policy_document" "codebuild_service" {
  statement {
      effect = "Allow"

      actions = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
      ]

      resources = ["*"]
  }

  statement {
      effect = "Allow"

      actions = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
      ]

      resources = ["*"]
  }

  statement {
      effect    = "Allow"
      actions   = ["ec2:CreateNetworkInterfacePermission"]
      resources = ["arn:aws:ec2:eu-west-1:${local.aws_account_number}:network-interface/*"]

    condition {
        test     = "StringEquals"
        variable = "ec2:Subnet"

        values = [
            aws_subnet.main.arn,
        ]
    }

    condition {
        test     = "StringEquals"
        variable = "ec2:AuthorizedService"
        values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    effect  = "Allow"
    actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.backend_pipeline_bucket.arn,
      "${aws_s3_bucket.backend_pipeline_bucket.arn}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = ["${data.aws_secretsmanager_secret.access_key.arn}"]
  }
}

resource "aws_iam_role_policy" "attach_policy_codebuild_role" {
  role   = aws_iam_role.custom_codebuild_service_role.name
  policy = data.aws_iam_policy_document.codebuild_service.json
}

######################################   CODEPIPELINE ROLE
data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "custom_codepipeline_service_role" {
    name               = "custom-codepipeline-service-role"
    assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json

    tags = {
        Name = "codepipeline-service-role"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

data "aws_iam_policy_document" "codepipeline_service" {
    statement {
        effect = "Allow"

        actions = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning",
            "s3:PutObjectAcl",
            "s3:PutObject",
        ]

        resources = [
            aws_s3_bucket.backend_pipeline_bucket.arn,
            "${aws_s3_bucket.backend_pipeline_bucket.arn}/*"
        ]
    }

    statement {
        effect = "Allow"

        actions = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild",
        ]

        resources = ["*"]
    }

    statement {
        effect = "Allow"

        actions = [
            "cloudwatch:*",
            "sns:*",
            "cloudformation:*",
            "rds:*",
            "sqs:*",
            "lambda:*"
        ]

        resources = ["*"]             
    }
}

resource "aws_iam_role_policy" "attach_policy_codepipeline_role" {
    name   = "attach-policy-with-codepipeline_role"
    role   = aws_iam_role.custom_codepipeline_service_role.name
    policy = data.aws_iam_policy_document.codepipeline_service.json
}
