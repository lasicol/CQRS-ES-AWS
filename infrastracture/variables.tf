# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "us-east-1"
}

variable "dynamoDbEventStoreTableName" {
  type    = string
  default = "blaszewski-EventStore"
}
variable "dynamoDbCoreTableName" {
  type    = string
  default = "blaszewski-Core"
}
