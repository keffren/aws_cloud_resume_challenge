# LAMBDA SERVICE ROLE
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
                "Resource": "arn:aws:logs:eu-west-1:958238255088:*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": [
                    "arn:aws:logs:eu-west-1:958238255088:log-group:/aws/lambda/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": "dynamoDB:*",
                "Resource": "arn:aws:dynamodb:eu-west-1:958238255088:table/resume-challenge-counter"
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