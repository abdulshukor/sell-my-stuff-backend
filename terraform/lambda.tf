# Define a local variable for the S3 bucket
# that stores Lambda deployment packages
locals {
  artifacts_bucket = "sell-my-stuff-backend-abdul-artifacts"
}


# Retrieve information about the Lambda deployment ZIP file from S3
data "aws_s3_object" "lambda_package" {

  # S3 bucket containing the Lambda package
  bucket = local.artifacts_bucket

  # Path to the Lambda ZIP file inside the bucket
  key = "artifacts/lambda_package.zip"
}


# Retrieve information about the Lambda dependencies ZIP file from S3
data "aws_s3_object" "dependencies" {

  # S3 bucket containing the dependencies package
  bucket = local.artifacts_bucket

  # Path to the dependencies ZIP file
  key = "artifacts/dependencies.zip"
}


# Allow API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "sell_my_stuff" {

  # Name of the Lambda function
  function_name = aws_lambda_function.sell_my_stuff.function_name

  # Unique identifier for this permission
  statement_id = "AllowAPIGatewayInvoke"

  # Allow Lambda function invocation
  action = "lambda:InvokeFunction"

  # Grant permission to API Gateway
  principal = "apigateway.amazonaws.com"

  # Restrict invocation permission to this API Gateway
  source_arn = "${aws_api_gateway_rest_api.sell_my_stuff.execution_arn}/*/*"
}


# Create the AWS Lambda function
resource "aws_lambda_function" "sell_my_stuff" {

  # Name of the Lambda function
  function_name = "sell-my-stuff"

  # Python file and function that handle Lambda requests
  handler = "sell_my_stuff.lambda_handler.lambda_handler"

  # Python runtime version
  runtime = "python3.13"

  # IAM role assigned to the Lambda function
  role = aws_iam_role.lambda_role.arn

  # S3 bucket containing the Lambda deployment ZIP
  s3_bucket = local.artifacts_bucket

  # S3 object key for the Lambda deployment package
  s3_key = data.aws_s3_object.lambda_package.key

  # S3 object version used for deployment
  s3_object_version = data.aws_s3_object.lambda_package.version_id

  # Attach the dependencies Lambda layer
  layers = [aws_lambda_layer_version.dependencies.arn]

  # Maximum execution time in seconds
  timeout = 300
}


# Create a Lambda layer containing Python dependencies
resource "aws_lambda_layer_version" "dependencies" {

  # Name of the Lambda layer
  layer_name = "dependencies"

  # S3 bucket containing the dependencies package
  s3_bucket = local.artifacts_bucket

  # Path to the dependencies ZIP file
  s3_key = data.aws_s3_object.dependencies.key

  # S3 object version containing the dependencies
  s3_object_version = data.aws_s3_object.dependencies.version_id

  # Python runtime compatible with this layer
  compatible_runtimes = ["python3.13"]
}
