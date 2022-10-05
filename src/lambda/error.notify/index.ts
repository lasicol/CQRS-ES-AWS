// Lambda function code
import {
  Context,
  APIGatewayProxyCallback,
  APIGatewayEvent,
  DynamoDBStreamEvent,
  CloudWatchLogsEvent,
  DynamoDBRecord,
} from "aws-lambda";
import { EEventType, IEvent } from "../../libs/event.types";

import zlib from "zlib";
var AWS = require("aws-sdk");
var sns = new AWS.SNS();

exports.handler = async (event: CloudWatchLogsEvent) => {
  console.log(event);

  const decoded = await decode(event.awslogs.data);
  console.log(decoded);

  const params = {
    Subject: decoded.logGroup,
    Message: JSON.stringify(decoded),
    TopicArn: "arn:aws:sns:us-east-1:890769921003:blaszewski-error-notify",
  };
  const data = await sns
    .publish(params)
    .promise()
    .catch((err: any) => {
      console.error(
        "Unable to send message. Error JSON:",
        JSON.stringify(err, null, 2)
      );
    });

  console.log("Results from sending message: ", JSON.stringify(data, null, 2));
};

const decode = async (data: string) => {
  const compressedPayload = Buffer.from(data, "base64");
  const jsonPayload = zlib.gunzipSync(compressedPayload).toString("utf8");
  return JSON.parse(jsonPayload);
};
