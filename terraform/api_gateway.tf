# Create an AWS API Gateway REST API
resource "aws_api_gateway_rest_api" "sell_my_stuff" {

  # Name of the API Gateway
  name = "sell_my_stuff"

  # Load the OpenAPI YAML configuration file
  # and pass the Lambda ARN and AWS region as variables
  body = templatefile("${path.module}/files/api/oas.yml", {

    # ARN of the Lambda function that handles API requests
    lambda_arn = aws_lambda_function.sell_my_stuff.arn

    # AWS region where the resources are deployed
    region = var.region
  })
}


# Create a deployment stage for the API Gateway
resource "aws_api_gateway_stage" "sell_my_stuff" {

  # ID of the REST API associated with this stage
  rest_api_id = aws_api_gateway_rest_api.sell_my_stuff.id

  # Name of the deployment stage
  stage_name = "prod"

  # Link this stage to the API Gateway deployment
  deployment_id = aws_api_gateway_deployment.sell_my_stuff.id
}


# Deploy the API Gateway REST API
resource "aws_api_gateway_deployment" "sell_my_stuff" {

  # ID of the REST API to deploy
  rest_api_id = aws_api_gateway_rest_api.sell_my_stuff.id

  # Automatically trigger a new deployment when
  # the API configuration changes
  triggers = {

    # Generate a hash of the API configuration
    # to detect changes and trigger redeployment
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.sell_my_stuff.body))
  }

  # Control how Terraform manages this resource
  lifecycle {

    # Create a new deployment before destroying the old one
    # to reduce downtime during updates
    create_before_destroy = true
  }
}


# Create a usage plan for the API Gateway
resource "aws_api_gateway_usage_plan" "sell_my_stuff" {

  # Name of the usage plan
  name = "sell-my-stuff-usage-plan"

  # Associate the usage plan with the API and its stage
  api_stages {

    # ID of the REST API
    api_id = aws_api_gateway_rest_api.sell_my_stuff.id

    # Deployment stage associated with the usage plan
    stage = aws_api_gateway_stage.sell_my_stuff.stage_name
  }
}


# Create an API key for accessing the API Gateway
resource "aws_api_gateway_api_key" "sell_my_stuff" {

  # Name of the API key
  name = "sell-my-stuff-api-key"
}


# Associate the API key with the API Gateway usage plan
resource "aws_api_gateway_usage_plan_key" "sell_my_stuff" {

  # ID of the usage plan
  usage_plan_id = aws_api_gateway_usage_plan.sell_my_stuff.id

  # ID of the API key
  key_id = aws_api_gateway_api_key.sell_my_stuff.id

  # Specify the type of key used for authentication
  key_type = "API_KEY"
}
