import { getExpectedVersion, getProductCategorytModel, getProductModel } from "./aggregation.store";
import {
  AddProductCategoryEvent,
  AddProductEvent,
  EventBase,
  UpdateProductEvent,
} from "./events";
import AWS from "aws-sdk";
import {
  validateProductCategoryModel,
  validateProductModel,
} from "./validator";
const docClient = new AWS.DynamoDB.DocumentClient();

type TRequestType = "POST" | "PUT" | "DELETE";

export async function productHandler(body: any, requestType: TRequestType) {

  let event: AddProductEvent | UpdateProductEvent;
  if (requestType === 'POST') {
      event = new AddProductEvent(body.uuid, body);
  }
  if (requestType === 'PUT') {
      event = new UpdateProductEvent(body.uuid, body);
  }

  const version = await getExpectedVersion(event.aggregateId);
  event.aggregateVersion = version;

  const model = await getProductModel({
    aggregateId: event.aggregateId,
    aggregateType: event.aggregateType,
  });
  try {
    await validateProductModel(model, event);
  } catch (e) {
    return "request not valid" + e.message;
  }
  await saveEvent(event);

  return "life is good";
}

export async function productCategoryHandler(body: any) {

  const event = new AddProductCategoryEvent(body.uuid, body);

  const model = await getProductCategorytModel({
    aggregateId: event.aggregateId,
    aggregateType: event.aggregateType,
  });
  try {
    await validateProductCategoryModel(model, event);
  } catch (e) {
    return "request not valid" + e.message;
  }
  await saveEvent(event);

  return "life is g00d";
}

async function saveEvent(event: EventBase) {
  const params = {
    TableName: "blaszewski-EventStore",

    Item: {
      ...event.generateObject(),
    },
  };

  console.log(params);

  try {
    const data = await docClient.put(params).promise();
    console.log("Success - item added or updated", data);
  } catch (err) {
    console.log("Error", err.stack);
  }
}
