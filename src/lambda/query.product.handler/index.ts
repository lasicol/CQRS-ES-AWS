// Lambda function code
import {
  APIGatewayEvent,
  APIGatewayProxyEventQueryStringParameters,
} from "aws-lambda";
import { Client, Connection } from "@opensearch-project/opensearch";
import { defaultProvider } from "@aws-sdk/credential-provider-node";
import aws4, { Credentials } from "aws4";

type QueryParams = {
  query: string | null;
  price: null | any;
  color: string | null;
};

exports.handler = async (event: APIGatewayEvent) => {
  console.log("Event: ", event);
  const params = parseParams(event.queryStringParameters);
  const resp = await getProducts(params);
  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      ...resp,
    }),
  };
};

function parseParams(params: APIGatewayProxyEventQueryStringParameters | null) {
  if (!params) return null;
  return Object.entries(params).reduce(
    (acc, cur) => {
      console.log(cur);

      const [key, value] = cur;
      if (key.includes("price")) {
        const filterKey = key?.split("[").pop()?.slice(0, -1);
        if (filterKey) {
          if (!acc.price) acc.price = {};

          acc.price[filterKey] = value;
        }
      }
      if (key === "color" && value) {
        acc.color = value;
      }
      if (key === "query" && value) {
        acc.query = value;
      }
      return acc;
    },
    { query: null, price: null, color: null } as QueryParams
  );
}

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

function getQueryObj(params: QueryParams | null) {
  let query;
  const must = [];
  if (params?.query) {
    must.push({
      query_string: {
        query: `*${params.query}*`,
        fields: ["name", "description"],
      },
    });
  }
  if (params?.price) {
    must.push({ range: { price: params.price } });
  }
  const filter = params?.color ? { term: { color: params.color } } : undefined;

  query = {
    query: {
      bool: {
        must,
        filter,
      },
    },
  };
  //   else {
  //     query = {
  //       query: {
  //         match_all: {},
  //       },
  //     };
  //   }

  return query;
}

async function getProducts(params: QueryParams | null) {
  // Initialize the client.
  const client = await getClient();

  const index_name = "product-index";

  var searchResp = await client.search({
    index: index_name,
    body: getQueryObj(params),
    pretty: true,
  });

  const response = searchResp?.body?.hits?.hits.map((hit: any) => hit._source);

  return response ? response : [];
}
