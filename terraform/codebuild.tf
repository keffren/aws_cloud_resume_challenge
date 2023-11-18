# Retrieve the programmatic credentials
data "aws_secretsmanager_secret" "access_key" {
    name = "dev/credentials/access_key"
}

# Create CodeBuild Project
resource "aws_codebuild_project" "cicd_build_stage" {
    name          = "CICD-Pipeline-Build-Stage"
    description   = "Build stage of the pipeline for the backend project"

    service_role = "${aws_iam_role.custom_codebuild_service_role.arn}"
    
    source {
    type            = "GITHUB"
    location        = "https://github.com/keffren/resume_challenge_backend"
    git_clone_depth = 1
    
    buildspec = <<-EOF
        version: 0.2
        env:
            variables:
                AWS_DEFAULT_REGION: "eu-west-1"
            secrets-manager:
                AWS_ACCESS_KEY_ID: ${data.aws_secretsmanager_secret.access_key.arn}:aws_access_key_id
                AWS_SECRET_ACCESS_KEY: ${data.aws_secretsmanager_secret.access_key.arn}:aws_secret_access_key
        phases:
            install:
                runtime-versions:
                    python: 3.11
                commands:
                    - python3 -m pip install boto3
                    - python3 -m pip install --upgrade awscli
        build:
            commands:
                - echo "Configuring AWS-CLI"
                - aws configure set region $AWS_DEFAULT_REGION
                - aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                - aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                - echo "Running unit tests"
                - python3 -m unittest tests/unit_tests.py
        artifacts:
            files:
                - '**/*'
    EOF

        git_submodules_config {
            fetch_submodules = true
        }
    }

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"

        privileged_mode = true
    }

    artifacts {
        type = "NO_ARTIFACTS"
    }

    logs_config {
        cloudwatch_logs {
            status = "DISABLED"
        }
        s3_logs {
            status = "DISABLED"
        }
    }

    tags = {
        Name = "CICD-Pipeline-Build-Stage"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}
