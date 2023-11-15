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

## CREATE OPTIONS METHOD FOR ENABLE CORS
resource "aws_api_gateway_method" "options_method_request" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration_request" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = aws_api_gateway_method.options_method_request.http_method
    type = "MOCK"
}

resource "aws_api_gateway_method_response" "options_method_response" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = aws_api_gateway_method.options_method_request.http_method
    status_code = "200"

    //Enable cors
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = aws_api_gateway_method.options_method_request.http_method
    status_code = aws_api_gateway_method_response.options_method_response.status_code

    //Enable cors
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }

    depends_on = [
        aws_api_gateway_method.get_method_request,
        aws_api_gateway_integration.get_integration_request
    ]
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

    //Enable cors
    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true
    }
}

resource "aws_api_gateway_integration_response" "get_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = aws_api_gateway_method.get_method_request.http_method
    status_code = aws_api_gateway_method_response.get_method_response.status_code

    //Enable cors
    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }

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
    status_code = "200"

    //Enable cors
    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true
    }
}

resource "aws_api_gateway_integration_response" "post_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.resume_challenge_api.id
    resource_id = aws_api_gateway_resource.visitor_counter.id
    http_method = aws_api_gateway_method.post_method_request.http_method
    status_code = aws_api_gateway_method_response.post_method_response.status_code

    //Enable cors
    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }

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

    triggers = {
        # NOTE: The configuration below will satisfy ordering considerations,
        #       but not pick up all future REST API changes. More advanced patterns
        #       are possible, such as using the filesha1() function against the
        #       Terraform configuration file(s) or removing the .id references to
        #       calculate a hash against whole resources. Be aware that using whole
        #       resources will show a difference after the initial implementation.
        #       It will stabilize to only change when resources change afterwards.
        redeployment = sha1(jsonencode([
            aws_api_gateway_resource.visitor_counter.id,
            aws_api_gateway_method.post_method_request.id,
            aws_api_gateway_method.get_method_request.id,
            aws_api_gateway_method.options_method_request.id,
            aws_api_gateway_integration.get_integration_request.id,
            aws_api_gateway_integration.post_integration_request.id,
            aws_api_gateway_integration.options_integration_request.id,
        ]))
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_api_gateway_stage" "dev" {
    deployment_id = aws_api_gateway_deployment.deployment.id
    rest_api_id   = aws_api_gateway_rest_api.resume_challenge_api.id
    stage_name    = "dev"
}
