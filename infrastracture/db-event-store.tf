resource "aws_dynamodb_table" "event_store" {
  name         = var.dynamoDbEventStoreTableName
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "eventId"

  attribute {
    name = "eventId"
    type = "S"
  }
  attribute {
    name = "aggregateId"
    type = "S"
  }
  attribute {
    name = "aggregateType"
    type = "S"
  }

  global_secondary_index {
    hash_key = "aggregateId"
    name = "aggregateId-index"
    projection_type = "ALL"
    range_key = "aggregateType"
  }

  tags = {
    "name" = "blaszewski-EventStore"
    "owner" = "blaszewski"
  }

  stream_enabled = true
  stream_view_type = "NEW_IMAGE"
  
}

resource "aws_sns_topic" "topic_events" {
  name                        = "blaszewski-topic_events.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
}

resource "aws_sqs_queue" "category_queue" {
  name                        = "blaszewski-category_queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}
resource "aws_sqs_queue" "product_queue" {
  name                        = "blaszewski-product_queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}

resource "aws_sns_topic_subscription" "category_sqs_subscription" {
  topic_arn = aws_sns_topic.topic_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.category_queue.arn
  filter_policy = <<POLICY
  {
   "aggregateType": ["Category"]
  }
  POLICY
}
resource "aws_sns_topic_subscription" "product_sqs_subscription" {
  topic_arn = aws_sns_topic.topic_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.product_queue.arn
  filter_policy = <<POLICY
  {
   "aggregateType": ["Product"]
  }
  POLICY
}

resource "aws_sqs_queue_policy" "sqs_sns_category_queue_policy" {
    queue_url = "${aws_sqs_queue.category_queue.id}"

    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.category_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.topic_events.arn}"
        }
      }
    }
  ]
}
POLICY
}
resource "aws_sqs_queue_policy" "sqs_sns_product_queue_policy" {
    queue_url = "${aws_sqs_queue.product_queue.id}"

    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.product_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.topic_events.arn}"
        }
      }
    }
  ]
}
POLICY
}