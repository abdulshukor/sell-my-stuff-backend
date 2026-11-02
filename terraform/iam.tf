# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {

  # Name of the IAM role
  name = "sell-my-stuff-lambda-role"

  # Load the trust policy that allows AWS Lambda
  # to assume this IAM role
  assume_role_policy = file("${path.module}/files/iam/assume_role.json")
}


# Create and attach an IAM policy to the Lambda role
resource "aws_iam_role_policy" "lambda_policy" {

  # Name of the IAM policy
  name = "sell-my-stuff-lambda-policy"

  # Attach the policy to the Lambda IAM role
  role = aws_iam_role.lambda_role.id

  # Load the permissions from the JSON policy file
  policy = file("${path.module}/files/iam/lambda_policy.json")
}
