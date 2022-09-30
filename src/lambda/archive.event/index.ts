// Lambda function code
import {
  Context,
  APIGatewayProxyCallback,
  APIGatewayEvent,
  SQSEvent,
} from "aws-lambda";
import {
  AddProductCategoryPayload,
  EEventType,
  IEvent,
} from "../../libs/event.types";
import AWS from "aws-sdk";

var s3 = new AWS.S3();
exports.handler = async (event: SQSEvent) => {
  for (let i = 0; i < event.Records.length; i++) {
    const record = event.Records[i];
    const message = JSON.parse(JSON.parse(record.body).Message);
    console.log(message);

    const key = `${message.aggregateType}/${message.aggregateId}/${message.aggregateVersion}`;
    try {
      const resp = await s3
        .putObject({
          Bucket: "blaszewski-archive-event",
          Key: key,
          Body: JSON.stringify(message.payload),
        })
        .promise();

      console.log(resp);
    } catch (e) {
      console.error(e);
    }
  }
};
