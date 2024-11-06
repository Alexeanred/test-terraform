provider "aws" {
  region = "us-east-1"
}

module "s3_bucket" {
    source = "./modules/S3"
}

module "sns_topic" {
  source = "./modules/SNS"
}

module "sqs_queue" {
  source = "./modules/SQS"
}

module "dynamodb_table" {
  source = "./modules/DYNAMODB"
}

module "lambda_function" {
  source = "./modules/LAMBDA"
  dynamo_table = module.dynamodb_table.table_name
  output_bucket = module.s3_bucket.html_bucket_name
}

resource "aws_s3_bucket_notification" "s3_event" {
  bucket = module.s3_bucket.markdown_bucket_name

  topic {
    topic_arn = module.sns_topic.topic_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_sns_topic_subscription" "sns_to_sqs_conversion" {
  topic_arn = module.sns_topic.topic_arn
  protocol = "sqs"
  endpoint = module.sqs_queue.sqs_arn_conversion
}

resource "aws_sns_topic_subscription" "sns_to_sqs_sentiment" {
  topic_arn = module.sns_topic.topic_arn
  protocol = "sqs"
  endpoint = module.sqs_queue.sqs_arn_sentiment
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_trigger_conversion" {
  event_source_arn = module.sqs_queue.sqs_arn_conversion
  function_name    = module.lambda_function.lambda_conversion_arn
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_trigger_sentiment" {
  event_source_arn = module.sqs_queue.sqs_arn_sentiment
  function_name    = module.lambda_function.lambda_sentiment_arn
}

output "s3_bucket_name_html" {
  value = module.s3_bucket.html_bucket_name
}

output "s3_bucket_name_markdown" {
  value = module.s3_bucket.markdown_bucket_name
}

output "domain_s3" {
  value = module.s3_bucket.website_domain
}

output "sns_topic_arn" {
  value = module.sns_topic.topic_arn
}

output "sqs_conversion_queue_arn" {
  value = module.sqs_queue.sqs_arn_conversion
}

output "sqs_sentiment_queue_arn" {
  value = module.sqs_queue.sqs_arn_sentiment
}

output "dynamodb_table_name" {
  value = module.dynamodb_table.table_name
}

output "lambda_conversion_arn" {
  value = module.lambda_function.lambda_conversion_arn
}

output "lambda_sentiment_arn" {
  value = module.lambda_function.lambda_sentiment_arn
}

output "s3_event_notification_id" {
  value = aws_s3_bucket_notification.s3_event.id
}

output "sns_to_sqs_conversion_subscription_arn" {
  value = aws_sns_topic_subscription.sns_to_sqs_conversion.id
}

output "sns_to_sqs_sentiment_subscription_arn" {
  value = aws_sns_topic_subscription.sns_to_sqs_sentiment.id
}

output "lambda_sqs_trigger_conversion_arn" {
  value = aws_lambda_event_source_mapping.lambda_sqs_trigger_conversion.arn
}

output "lambda_sqs_trigger_sentiment_arn" {
  value = aws_lambda_event_source_mapping.lambda_sqs_trigger_sentiment.arn
}
