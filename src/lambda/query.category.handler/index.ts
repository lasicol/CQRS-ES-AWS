// Lambda function code
import { APIGatewayEvent } from "aws-lambda";
import AWS from "aws-sdk";
const docClient = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event: APIGatewayEvent) => {
  console.log("Event: ", event);
  const resp = await getCategories();
  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      resp,
    }),
  };
};

async function getCategories() {
  const params = {
    TableName: "blaszewski-Core",
    ReturnConsumedCapacity: "TOTAL",
  };

  try {
    const data = await docClient.scan(params).promise();
    console.log("Success - item added or updated", data);
    return data.Items;
  } catch (err) {
    if (err instanceof Error) console.log("Error", err.stack);
  }
}
