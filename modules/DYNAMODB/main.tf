resource "aws_dynamodb_table" "simple-table" {
  name = "SentimentAnalysisResults1"
  hash_key = "FileKey"
  billing_mode = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  attribute {
    name = "FileKey"
    type = "S"
  }
}


output "table_name" {
  value = aws_dynamodb_table.simple-table.name
}