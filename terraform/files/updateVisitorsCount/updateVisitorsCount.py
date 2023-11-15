import json
import boto3

def updateVisitorsCount_handler(event, context):
    
    #Connect to DynamoDB and retrieve the item
    dynamodb = boto3.resource('dynamodb', region_name='eu-west-1')
    table_name = "resume-challenge-counter"
    table = dynamodb.Table(table_name)
    visitors_count_item_att = event["item_to_update"]
    
    # Get the item
    item = table.get_item(Key={"CounterId": "mainCounter"})
    
    #Get the value of visitorsNumber attribute
    visitors_count_value = int(item["Item"][visitors_count_item_att])
    
    #Increment the counter
    visitors_count_value += 1
    
    #Update the DB
    update_request = table.update_item(
        Key={"CounterId": "mainCounter"},
        # Expression attribute names specify placeholders for attribute names to use in your update expressions.
        ExpressionAttributeNames={
            "#visitorsNumber": "visitorsNumber",
        },
        # Expression attribute values specify placeholders for attribute values to use in your update expressions.
        ExpressionAttributeValues={
            ":count": visitors_count_value,
        },
        # UpdateExpression declares the updates you want to perform on your item.
        # For more details about update expressions, see https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Expressions.UpdateExpressions.html
        UpdateExpression="SET #visitorsNumber = :count",
    )
    
    #Return request status
    resp = update_request["ResponseMetadata"]
    
    if resp["HTTPStatusCode"] == 200:
        message = "The visitors counter has been updated"
    else:
        message = "Ups! something is wrong"
    
    return {
        "statusCode": resp["HTTPStatusCode"],
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps({
            "message": message
        })
    }
    