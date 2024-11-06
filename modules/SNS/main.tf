resource "aws_sns_topic" "s3_notification_topic" {
  name = "S3EventNotificationPubMessaging1"
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.s3_notification_topic.arn

  policy = data.aws_iam_policy_document.topic_policy.json
}

data "aws_iam_policy_document" "topic_policy" {
    policy_id = "example-ID"

    statement {
      sid = "example SNS topic policy"
      effect = "Allow"
      principals {
        type = "Service"
        identifiers = [
            "s3.amazonaws.com",
        ]
      }
      actions = [
        "SNS:Publish",
      ]
      resources = [
        aws_sns_topic.s3_notification_topic.arn,
      ]
      condition {
        test = "StringEquals"
        variable = "AWS:SourceAccount"
        values = ["471112789042"]
      }

      condition {
        test = "ArnLike"
        variable = "aws:SourceArn"
        values = ["arn:aws:s3:*:*:markdown-files-030915"]
      }
    }
}

output "topic_arn" {
  value = aws_sns_topic.s3_notification_topic.arn
}