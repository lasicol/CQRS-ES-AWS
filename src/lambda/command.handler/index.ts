// Lambda function code
import { Context, APIGatewayProxyCallback, APIGatewayEvent } from 'aws-lambda';
import { productCategoryHandler, productHandler } from './product-handler';


// function productCategoryHandler() {
//     return 'welcome in product category handler'
// }


module.exports.handler = async (event: APIGatewayEvent) => {
    console.log('Event: ', event);
    let responseMessage = '';
    if (event.httpMethod === 'POST') {
        if (event.resource == '/product') {
            responseMessage = await productHandler(JSON.parse(event.body), 'POST');
        }
        if (event.resource == '/product_category') {
            responseMessage = await productCategoryHandler(JSON.parse(event.body));
        }
    }
  
    if (event.httpMethod === 'PUT') {
        if (event.resource == '/product') {
            responseMessage = await productHandler(JSON.parse(event.body), 'PUT');
        }
    }
  
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: responseMessage,
      }),
    }
  }
  