resource "aws_sqs_queue" "conversionQueue" {
  name = "conversionQueue1"
}

resource "aws_sqs_queue" "sentimentQueue" {
  name = "sentimentQueue1"
}

resource "aws_sqs_queue_policy" "conversion_queue_policy" {
  queue_url = aws_sqs_queue.conversionQueue.id
  policy    = data.aws_iam_policy_document.conversion_queue_policy.json
}

resource "aws_sqs_queue_policy" "sentiment_queue_policy" {
  queue_url = aws_sqs_queue.sentimentQueue.id
  policy    = data.aws_iam_policy_document.sentiment_queue_policy.json
}

data "aws_iam_policy_document" "conversion_queue_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.conversionQueue.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:sns:us-east-1:471112789042:S3EventNotificationPubMessaging1"]
    }
  }

  statement {
    sid       = "topic-subscription-arn:aws:sns:us-east-1:471112789042:S3EventNotificationPubMessaging1"
    effect    = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.conversionQueue.arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:sns:us-east-1:471112789042:S3EventNotificationPubMessaging1"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:CreateEventSourceMapping",
      "lambda:ListEventSourceMappings",
      "lambda:ListFunctions"
    ]
    resources = ["arn:aws:lambda:us-east-1:471112789042:function:ConversionService1"]
  }
}

data "aws_iam_policy_document" "sentiment_queue_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.sentimentQueue.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:sns:us-east-1:471112789042:S3EventNotificationPubMessaging1"]
    }
  }

  statement {
    sid       = "topic-subscription-arn:aws:sns:us-east-1:471112789042:S3EventNotificationPubMessaging1"
    effect    = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.sentimentQueue.arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:sns:us-east-1:471112789042:S3EventNotificationPubMessaging1"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:CreateEventSourceMapping",
      "lambda:ListEventSourceMappings",
      "lambda:ListFunctions"
    ]
    resources = ["arn:aws:lambda:us-east-1:471112789042:function:SentimentAnalysis1"]
  }
}

output "sqs_arn_conversion" {
  value = aws_sqs_queue.conversionQueue.arn
}

output "sqs_arn_sentiment" {
  value = aws_sqs_queue.sentimentQueue.arn
}