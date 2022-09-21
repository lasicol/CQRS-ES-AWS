// Lambda function code
import { Context, APIGatewayProxyCallback, APIGatewayEvent, DynamoDBStreamEvent } from 'aws-lambda';

var AWS = require("aws-sdk");
var sns = new AWS.SNS();

exports.handler = (event: DynamoDBStreamEvent, context: any, callback: any) => {

    event.Records.forEach((record: any) => {
        console.log('Stream record: ', JSON.stringify(record, null, 2));

        if (record.eventName == 'INSERT') {
            var who = JSON.stringify(record.dynamodb.NewImage.eventId.S);
            // var when = JSON.stringify(record.dynamodb.NewImage.Timestamp.S);
            // var what = JSON.stringify(record.dynamodb.NewImage.Message.S);
            var params = {
                Subject:  who,
                Message: who,
                MessageGroupId: 'event',
                TopicArn: 'arn:aws:sns:us-east-1:890769921003:blaszewski-new_event.fifo'
            };
             sns.publish(params, function(err:any, data:any) {
                if (err){
                    console.error("Unable to send message. Error JSON:", JSON.stringify(err, null, 2));
                } else {
                    console.log("Results from sending message: ", JSON.stringify(data, null, 2));
                }
            });
        }
    });
    callback(null, `Successfully processed ${event.Records.length} records.`);
};  