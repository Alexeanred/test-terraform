# IAM Role for Conversion Lambda Function
resource "aws_iam_role" "lambda_role_conversion" {
  name = "lambda_execution_role_conversion"

  assume_role_policy = jsonencode({
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
  })
}

# CloudWatch Policy for Conversion Lambda Function
resource "aws_iam_policy" "cloudwatch_policy_conversion" {
  name = "cloudwatch_policy_conversion"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-east-1:471112789042:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:471112789042:log-group:/aws/lambda/ConversionService1:*"
            ]
        }
    ]
  })
}

# SQS Policy for Conversion Lambda Function
resource "aws_iam_policy" "sqs_policy_conversion" {
  name = "sqs_policy_conversion"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes",
                "sqs:ReceiveMessage"
            ],
            "Resource": "arn:aws:sqs:us-east-1:471112789042:conversionQueue1"
        }
    ]
  })
}

# Attach Policies to Conversion Lambda Role
resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment_conversion" {
  role       = aws_iam_role.lambda_role_conversion.name
  policy_arn = aws_iam_policy.cloudwatch_policy_conversion.arn
}

resource "aws_iam_role_policy_attachment" "sqs_policy_attachment_conversion" {
  role       = aws_iam_role.lambda_role_conversion.name
  policy_arn = aws_iam_policy.sqs_policy_conversion.arn
}

resource "aws_iam_role_policy_attachment" "s3_full_access_attachment_conversion" {
  role       = aws_iam_role.lambda_role_conversion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


# IAM Role for SentimentAnalysis Lambda Function
resource "aws_iam_role" "lambda_role_sentiment" {
  name = "lambda_execution_role_sentiment"

  assume_role_policy = jsonencode({
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
  })
}

# CloudWatch Policy for SentimentAnalysis Lambda Function
resource "aws_iam_policy" "cloudwatch_policy_sentiment" {
  name = "cloudwatch_policy_sentiment"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-east-1:471112789042:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:471112789042:log-group:/aws/lambda/SentimentService1:*"
            ]
        }
    ]
  })
}

resource "aws_iam_policy" "sqs_policy_sentiment" {
  name = "sqs_policy_sentiment"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes",
                "sqs:ReceiveMessage"
            ],
            "Resource": "arn:aws:sqs:us-east-1:471112789042:sentimentQueue1"
        }
    ]
  })
}
# Attach Full Access Policies to SentimentAnalysis Lambda Role
resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment_sentiment" {
  role       = aws_iam_role.lambda_role_sentiment.name
  policy_arn = aws_iam_policy.cloudwatch_policy_sentiment.arn
}

resource "aws_iam_role_policy_attachment" "s3_full_access_attachment_sentiment" {
  role       = aws_iam_role.lambda_role_sentiment.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access_attachment_sentiment" {
  role       = aws_iam_role.lambda_role_sentiment.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "comprehend_full_access_attachment_sentiment" {
  role       = aws_iam_role.lambda_role_sentiment.name
  policy_arn = "arn:aws:iam::aws:policy/ComprehendFullAccess"
}

resource "aws_iam_role_policy_attachment" "sqs_policy_attachment_sentiment" {
  role       = aws_iam_role.lambda_role_sentiment.name
  policy_arn = aws_iam_policy.sqs_policy_sentiment.arn # Reuse SQS policy from Conversion Lambda if queues are the same
}

resource "aws_lambda_layer_version" "conversion_layer" {
  layer_name = "conversion_layer"
  compatible_runtimes = ["python3.12"]
  filename = "${path.module}/layer/python-markdown.zip"
  source_code_hash = filebase64sha256("${path.module}/layer/python-markdown.zip")
}

resource "aws_lambda_layer_version" "sentiment_layer" {
  layer_name = "sentiment_layer"
  compatible_runtimes = ["python3.12"]
  filename = "${path.module}/layer/python-bs4-markdown.zip"
  source_code_hash = filebase64sha256("${path.module}/layer/python-bs4-markdown.zip")
}

resource "aws_lambda_function" "conversion_function" {
  function_name = "ConversionService1"
  runtime       = "python3.12"
  handler       = "conversion.lambda_handler"
  role          = aws_iam_role.lambda_role_conversion.arn

  filename         = "${path.module}/code/conversion.zip"
  source_code_hash = filebase64sha256("${path.module}/code/conversion.zip")

  layers = [
    aws_lambda_layer_version.conversion_layer.arn
  ]

  environment {
    variables = {
       OUTPUT_BUCKET = var.output_bucket
    }
  }
}

resource "aws_lambda_function" "sentiment_function" {
  function_name = "SentimentService1"
  runtime       = "python3.12"
  handler       = "sentiment.lambda_handler"
  role          = aws_iam_role.lambda_role_sentiment.arn

  filename         = "${path.module}/code/sentiment.zip"
  source_code_hash = filebase64sha256("${path.module}/code/sentiment.zip")

  layers = [
    aws_lambda_layer_version.sentiment_layer.arn
  ]

  environment {
    variables = {
       DYNAMODB_TABLE = var.dynamo_table
    }
  }
}


output "lambda_conversion_arn" {
  value = aws_lambda_function.conversion_function.arn
}

output "lambda_sentiment_arn" {
  value = aws_lambda_function.sentiment_function.arn
}