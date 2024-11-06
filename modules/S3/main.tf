resource "aws_s3_bucket" "markdown_bucket" {
    bucket = "markdown-files-030915"
}

resource "aws_s3_bucket" "html_output_bucket" {
    bucket = "html-converted-output-030915"
}


resource "aws_s3_bucket_website_configuration" "html_output_website" {
    bucket = aws_s3_bucket.html_output_bucket.id
    index_document {
    suffix = "_index.html"
  }
}

resource "aws_s3_bucket_policy" "allow_get_object"{
    bucket = aws_s3_bucket.html_output_bucket.id
    policy = data.aws_iam_policy_document.allow_get_object.json
    depends_on = [ aws_s3_bucket_public_access_block.bucket_public_access_block ]
}

data "aws_iam_policy_document" "allow_get_object"{
    statement {
      sid = "PublicReadGetObject"

      effect = "Allow"

      actions = [
        "s3:GetObject",
      ]

      resources = [
         "${aws_s3_bucket.html_output_bucket.arn}/*",
      ]

      principals {
        type = "AWS"
        identifiers = ["*"]
      }
    }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.html_output_bucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

output "markdown_bucket_name" {
  value = aws_s3_bucket.markdown_bucket.id
}

output "website_domain" {
  value = aws_s3_bucket_website_configuration.html_output_website.website_domain
}

output "html_bucket_name" {
  value = aws_s3_bucket.html_output_bucket.id
}
