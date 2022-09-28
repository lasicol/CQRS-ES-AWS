// Lambda function code
import {
  APIGatewayEvent,
  APIGatewayProxyEventQueryStringParameters,
} from "aws-lambda";
import { Client, Connection } from "@opensearch-project/opensearch";
import { defaultProvider } from "@aws-sdk/credential-provider-node";
import aws4, { Credentials } from "aws4";

exports.handler = async (event: APIGatewayEvent) => {
  console.log("Event: ", event);
  const resp = await getProducts(event.queryStringParameters);
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

function getQueryObj(params: APIGatewayProxyEventQueryStringParameters | null) {
  let query;
  if (params?.query) {
    query = {
      query: {
        "multi_match": {
            "query": params.query,
            "fields": [
              "name",
              "description"
            ]
          }
      },
    };
  } else {
    query = {
      query: {
        match_all: {},
      },
    };
  }

  console.log(query);

  return query;
}

async function getProducts(params: APIGatewayProxyEventQueryStringParameters | null) {
  // Initialize the client.
  const client = await getClient();

  // Create an index.

  const index_name = "product-index";

  var response = await client.search({
    index: index_name,
    body: getQueryObj(params),
    pretty: true,
  });

  console.log("Search results:");
  console.log(response.body);

  return response.body;
}
