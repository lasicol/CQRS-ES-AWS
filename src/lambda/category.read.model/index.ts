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
const docClient = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event: SQSEvent) => {
  for (let i = 0; i < event.Records.length; i++) {
    const record = event.Records[i];
    const message = JSON.parse(JSON.parse(record.body).Message);
    console.log(message);
    
    if (message.aggregateType === "Category") {
      if (message.eventType === EEventType.AddProductCategory) {
        await createCategory(message.aggregateId, message.payload);
      }
    }
  }
};

async function createCategory(
  aggregateId: string,
  payload: AddProductCategoryPayload
) {
  const params = {
    TableName: "blaszewski-Core",

    Item: {
      categoryUuid: aggregateId,
      ...payload,
    },
  };

  try {
    const data = await docClient.put(params).promise();
    console.log("Success - item added", data);
  } catch (err) {
    if (err instanceof Error) {
        if (err.stack) console.error("Error", err.stack);
    }
    else {
        console.error(err);
    }
    
  }
}
