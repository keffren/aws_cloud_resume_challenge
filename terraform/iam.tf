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
                "Resource": "${aws_dynamodb_table.visitor_counter.arn}"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:PutObject",
                    "s3:GetObject",
                    "s3:GetObjectVersion",
                    "s3:GetBucketAcl",
                    "s3:GetBucketLocation"
                ],
                "Resource": [
                    "${aws_s3_bucket.backend_pipeline_bucket.arn}",
                    "${aws_s3_bucket.backend_pipeline_bucket.arn}/*",
                ]
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

  statement {
    effect = "Allow"
    actions = ["lambda:*"]
    resources = [
        "${aws_lambda_function.getVisitorsCount_function.arn}",
        "${aws_lambda_function.updateVisitorsCount_function.arn}"
    ]
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
            "sqs:*"
        ]

        resources = ["*"]             
    }
}

resource "aws_iam_role_policy" "attach_policy_codepipeline_role" {
    name   = "attach-policy-with-codepipeline_role"
    role   = aws_iam_role.custom_codepipeline_service_role.name
    policy = data.aws_iam_policy_document.codepipeline_service.json
}

######################################  CI/CD Front-End
resource "aws_iam_policy" "frontend_s3_access" {
    name        = "frontend-s3-access"
    description = "Grant S3 access to CICD Frontend GitHub Actions"

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:*"
                ],
                "Resource": [
                    "${aws_s3_bucket.static_website.arn}",
                    "${aws_s3_bucket.static_website.arn}/*"
                ]
            }
        ]
    })

    tags = {
        Name = "frontend-s3-access"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

resource "aws_iam_role" "frontend_cicd_role" {
    name = "frontend-cicd-service-role"
  
    assume_role_policy = <<-EOF
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": "sts:AssumeRoleWithWebIdentity",
                    "Principal": {
                        "Federated": "arn:aws:iam::${local.aws_account_number}:oidc-provider/token.actions.githubusercontent.com"
                    },
                    "Condition": {
                        "StringEquals": {
                            "token.actions.githubusercontent.com:aud": [
                                "sts.amazonaws.com"
                            ],
                            "token.actions.githubusercontent.com:sub": [
                                "repo:keffren/resume_challenge_frontend:ref:refs/heads/main"
                            ]
                        }
                    }
                }
            ]
        }
    EOF

    tags = {
        Name = "frontend-cicd-service-role"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

resource "aws_iam_role_policy_attachment" "frontend_cicd_role" {
  role       = aws_iam_role.frontend_cicd_role.name
  policy_arn = aws_iam_policy.frontend_s3_access.arn
}

resource "aws_iam_openid_connect_provider" "frontend_cicd_oidc" {

    //The URL of the identity provider
    url = "https://token.actions.githubusercontent.com"

    // A list of client IDs (also known as audiences)
    client_id_list = [
        "sts.amazonaws.com"
    ]

    thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]

    tags = {
        Name = "frontend-cicd-OIDC"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}
