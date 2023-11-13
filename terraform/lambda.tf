# GetVisitorsCount LAMBDA FUNCTION
data "archive_file" "getVisitorsCount_zip" {
  type        = "zip"
  source_file = "${path.module}/files/getVisitorsCount/getVisitorsCount.py"
  output_path = "${path.module}/files/getVisitorsCount/init.zip"
}

resource "aws_lambda_function" "getVisitorsCount_function" {
    filename      = "${path.module}/files/getVisitorsCount/init.zip"
    function_name = "getVisitorsCount"
    role          = aws_iam_role.lambda_service.arn
    handler       = "getVisitorsCount.getVisitorsCount_handler"

    runtime = "python3.11"

    tags = {
        Name = "getVisitorsCount-function"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

# updateVisitorsCount LAMBDA FUNCTION
data "archive_file" "updateVisitorsCount_zip" {
  type        = "zip"
  source_file = "${path.module}/files/updateVisitorsCount/updateVisitorsCount.py"
  output_path = "${path.module}/files/updateVisitorsCount/init.zip"
}

resource "aws_lambda_function" "updateVisitorsCount_function" {
    filename      = "${path.module}/files/updateVisitorsCount/init.zip"
    function_name = "updateVisitorsCount"
    role          = aws_iam_role.lambda_service.arn
    handler       = "updateVisitorsCount.updateVisitorsCount_handler"

    runtime = "python3.11"

    tags = {
        Name = "updateVisitorsCount-function"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}
