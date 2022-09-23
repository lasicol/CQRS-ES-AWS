resource "aws_dynamodb_table" "core" {
  name         = var.dynamoDbCoreTableName
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "categoryUuid"
  range_key = "name"
  
  attribute {
    name = "categoryUuid"
    type = "S"
  }
  attribute {
    name = "name"
    type = "S"
  }

  tags = {
    "name" = "blaszewski-core"
    "owner" = "blaszewski"
  }
  
}
