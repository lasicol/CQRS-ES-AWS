// Lambda function code
import {
  Context,
  APIGatewayProxyCallback,
  APIGatewayEvent,
  DynamoDBStreamEvent,
  DynamoDBRecord,
} from "aws-lambda";
import { EEventType, IEvent } from "../../libs/event.types";

var AWS = require("aws-sdk");
var sns = new AWS.SNS();

exports.handler = (event: DynamoDBStreamEvent, context: any, callback: any) => {
  const newImages = event.Records.reduce((acc: IEvent[], record) => {
    const converted = AWS.DynamoDB.Converter.unmarshall(
      record?.dynamodb?.NewImage
    );
    if (converted) {
      acc.push(converted);
    }
    return acc;
  }, []);
  newImages.forEach((image) => {
    const message = {
      ...image,
    };

    const params = {
      Subject: message.eventId,
      Message: JSON.stringify(message),
      MessageGroupId: "event",
      TopicArn:
        image.eventType === EEventType.AddProductCategory
          ? "arn:aws:sns:us-east-1:890769921003:blaszewski-category_events.fifo"
          : "arn:aws:sns:us-east-1:890769921003:blaszewski-product_events.fifo",
    };
    sns.publish(params, function (err: any, data: any) {
      if (err) {
        console.error(
          "Unable to send message. Error JSON:",
          JSON.stringify(err, null, 2)
        );
      } else {
        console.log(
          "Results from sending message: ",
          JSON.stringify(data, null, 2)
        );
      }
    });
  });
  callback(null, `Successfully processed ${event.Records.length} records.`);
};
