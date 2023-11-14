import json
import boto3

def getVisitorsCount_handler(event, context):
    
    #Connect to DynamoDB and retrieve the item
    dynamodb = boto3.resource('dynamodb', region_name='eu-west-1')
    
    table_name = event["table_name"]
    table = dynamodb.Table(table_name)
    item = table.get_item(Key={"CounterId": "mainCounter"})
    
    #Get the counter value
    counter_value = item["Item"]["visitorsNumber"]
    
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(counter_value)
    }
