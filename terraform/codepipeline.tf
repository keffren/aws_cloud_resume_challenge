# Retrieve the GitHub token secret
data "aws_secretsmanager_secret" "github_token" {
    name = "dev/codepipeline"
}

data "aws_secretsmanager_secret_version" "github_token_current" {
    secret_id = data.aws_secretsmanager_secret.github_token.arn
}

#Retrieve the GitHub WebHook Secret
data "aws_secretsmanager_secret" "webhook" {
    name = "dev/codepipeline/webhook"
}

data "aws_secretsmanager_secret_version" "webhook_current" {
    secret_id = data.aws_secretsmanager_secret.webhook.arn
}

locals {
    github_token = jsondecode(data.aws_secretsmanager_secret_version.github_token_current.secret_string)["resume-challenge-repository-token"]
    webhook_secret = jsondecode(data.aws_secretsmanager_secret_version.webhook_current.secret_string)["webhook"]
}

# CICD PIPELINE
resource "aws_codepipeline" "backend_pipeline" {
    name     = "CICD-Resume-BackEnd"
    role_arn = aws_iam_role.custom_codepipeline_service_role.arn

    artifact_store {
        location = aws_s3_bucket.backend_pipeline_bucket.bucket
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
            name            = "SourceAction"
            category        = "Source"
            owner           = "ThirdParty"
            provider        = "GitHub"
            version         = "1"  # GitHub version 1
            output_artifacts = ["source_output"]

            configuration = {
                Owner               = "keffren"
                Repo                = "resume_challenge_backend"
                Branch              = "main"
                OAuthToken          = local.github_token
                PollForSourceChanges = "false" #It'll use webhooks
            }
        }
    }

    stage {
        name = "Build"

        action {
            name             = "BuildAction"
            category         = "Build"
            owner            = "AWS"
            provider         = "CodeBuild"
            region           = "eu-west-1"

            input_artifacts  = ["source_output"]
            #output_artifacts = ["build_output"]
            version          = "1"

            configuration = {
                ProjectName = aws_codebuild_project.cicd_build_stage.name
            }
        }
    }
    
    tags = {
        Name = "CICD-Resume-BackEnd"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

resource "aws_codepipeline_webhook" "github_webhook_integration" {
    name            = "resume-challenge-backend-webhook"
    authentication  = "GITHUB_HMAC"
    target_action   = "Source"
    target_pipeline = aws_codepipeline.backend_pipeline.name

    authentication_configuration {
        secret_token = local.webhook_secret
    }

    filter {
        json_path    = "$.ref"
        match_equals = "refs/heads/main"
    }
}
