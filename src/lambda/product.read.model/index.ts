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

import { Client, Connection } from "@opensearch-project/opensearch";
import { defaultProvider } from "@aws-sdk/credential-provider-node";
import aws4, { Credentials } from "aws4";

exports.handler = async (event: SQSEvent) => {
  for (let i = 0; i < event.Records.length; i++) {
    const record = event.Records[i];
    const message = JSON.parse(JSON.parse(record.body).Message);
    const docToStore = {
        aggregateId: message.aggregateId,
        ...message.payload
    }
    await addDoc(docToStore).catch(console.log);
  }
};

var host =
  "https://search-product-search-gmhenolbzxybgtwgkm6qi5v6u4.us-east-1.es.amazonaws.com"; // e.g. https://my-domain.region.es.amazonaws.com

const createAwsConnector = (credentials: Credentials, region: string) => {
  class AmazonConnection extends Connection {
    buildRequestObject(params: any) {
      const request: any = super.buildRequestObject(params);
      request.service = "es";
      request.region = region;
      request.headers = request.headers || {};
      request.headers["host"] = request.hostname;

      return aws4.sign(request, credentials);
    }
  }
  return {
    Connection: AmazonConnection,
  };
};

const getClient = async () => {
  const credentials = await defaultProvider()();
  return new Client({
    ...createAwsConnector(credentials, "us-east-1"),
    node: host,
  });
};

async function addDoc(doc: any) {
  // Initialize the client.
  const client = await getClient();

  // Create an index.
  const index_name = "product-index";

  if (!(await client.indices.exists({ index: index_name }))) {
    const response = await client.indices.create({
      index: index_name,
    });

    console.log("Creating index:");
    console.log(response.body);
  }

  const response = await client.index({
    id: doc.aggregateId,
    index: index_name,
    body: doc,
  });
  console.log(response);
}
