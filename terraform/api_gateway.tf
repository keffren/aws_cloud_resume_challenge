# CREATE THE API
resource "aws_api_gateway_rest_api" "resume_challenge_api" {
    name = "Resume-Challenge-API"
    description = "Resume Challenge API Gateway"

    endpoint_configuration {
        types = ["EDGE"]
    }

    tags = {
        Name = "Resume-Challenge-API"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

resource "aws_api_gateway_resource" "visitor_counter" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    parent_id = aws_api_gateway_rest_api.resume_challenge_api.root_resource_id
    path_part = "visitor-counter"
}

## CREATE GET METHOD WITH LAMBDA INTEGRATION
resource "aws_api_gateway_method" "get_method_request" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_integration_request" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = aws_api_gateway_method.get_method_request.http_method
    integration_http_method = "POST"
    type = "AWS"
    uri = aws_lambda_function.getVisitorsCount_function.invoke_arn
}

resource "aws_api_gateway_method_response" "get_method_response" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = aws_api_gateway_method.get_method_request.http_method
    status_code = "200"
}

resource "aws_api_gateway_integration_response" "get_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = aws_api_gateway_method.get_method_request.http_method
    status_code = aws_api_gateway_method_response.get_method_response.status_code

    depends_on = [
        aws_api_gateway_method.get_method_request,
        aws_api_gateway_integration.get_integration_request
    ]
}

### Granting Lambda Permissions to the GET API Gateway method
resource "aws_lambda_permission" "apigw_invoke_lambda" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.getVisitorsCount_function.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_api_gateway_rest_api.resume_challenge_api.execution_arn}/*/*/*"
}

## CREATE POST METHOD WITH LAMBDA INTEGRATION
resource "aws_api_gateway_method" "post_method_request" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = "POST"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_integration_request" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = aws_api_gateway_method.post_method_request.http_method
    integration_http_method = "POST"
    type = "AWS"
    uri = aws_lambda_function.updateVisitorsCount_function.invoke_arn
}

resource "aws_api_gateway_method_response" "post_method_response" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = aws_api_gateway_method.post_method_request.http_method
    status_code = "201"
}

resource "aws_api_gateway_integration_response" "post_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = aws_api_gateway_method.post_method_request.http_method
    status_code = aws_api_gateway_method_response.post_method_response.status_code

    depends_on = [
        aws_api_gateway_method.post_method_request,
        aws_api_gateway_integration.post_integration_request
    ]
}

### Granting Lambda Permissions to the GET API Gateway method
resource "aws_lambda_permission" "apigw_invoke_update_lambda" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.updateVisitorsCount_function.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_api_gateway_rest_api.resume_challenge_api.execution_arn}/*/*/*"
}

# Deploy the API
resource "aws_api_gateway_deployment" "deployment" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id

    lifecycle {
        create_before_destroy = true
    }

    depends_on = [ 
        aws_api_gateway_integration.get_integration_request,
        aws_api_gateway_integration.post_integration_request
    ]
}

resource "aws_api_gateway_stage" "api_stage" {
    deployment_id = aws_api_gateway_deployment.deployment.id
    rest_api_id   = aws_api_gateway_rest_api.resume_challenge_api.id
    stage_name    = "dev"
}
