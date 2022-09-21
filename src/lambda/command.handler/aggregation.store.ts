import AWS from "aws-sdk";
import { EEventType, IEvent } from "../../libs/event.types";
const docClient = new AWS.DynamoDB.DocumentClient();

export async function getExpectedVersion(aggregateId: string) {
    const res = await queryDb(aggregateId, 1);
    if (res.length) {
        const version = res.pop().aggregateVersion;
        return  version ? version + 1 : 1; 
    }
    return 1;
}

export async function getProductModel(props: {
  aggregateId: string;
  aggregateType: string;
}) {
    const items = await queryDb(props.aggregateId);
    const model = buildProductAggregate(items as IEvent[]);
    return model;
}
export async function getProductCategorytModel(props: {
  aggregateId: string;
  aggregateType: string;
}) {
    const items = await queryDb(props.aggregateId);
    const model = buildProductCategoryAggregate(items as IEvent[]);
    return model;
}

function buildProductAggregate(items: IEvent[]) {
    let model: any = null;
    for (let i = 0; i < items.length; i++) {
        const item = items[i];
        if (item.eventType === EEventType.AddProduct) {
            model = {
                ...item.payload
            }
        }
        if (item.eventType === EEventType.UpdateProduct) {
            model = {
                ...model,
                ...item.payload
            }
        }
        if (item.eventType === EEventType.DeleteProduct) {
            model = null
        }
    }
    return model;
}

function buildProductCategoryAggregate(items: IEvent[]) {
    let model: any = null;
    for (let i = 0; i < items.length; i++) {
        const item = items[i];
        if (item.eventType === EEventType.AddProductCategory) {
            model = {
                ...item.payload
            }
        }
    }
    return model;
}

async function queryDb(aggregateId: string, limit?: number) {
  const params: AWS.DynamoDB.DocumentClient.QueryInput = {
    ExpressionAttributeNames: { "#id": "aggregateId" },
    TableName: "blaszewski-EventStore", // use environments
    IndexName: "aggregateId-index", // use envs
    ExpressionAttributeValues: {
      ":idValue": aggregateId,
    },
    KeyConditionExpression: "#id = :idValue",
  };

  if (limit) {
    params.Limit = limit;
  }

  const data = await docClient.query(params).promise();
  return data.Items;
}
