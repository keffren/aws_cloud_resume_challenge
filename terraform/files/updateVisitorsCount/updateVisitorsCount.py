import boto3

def updateVisitorsCount_handler(event, context):
    
    #Connect to DynamoDB and retrieve the item
    dynamodb = boto3.resource('dynamodb', region_name='eu-west-1')
    table_name = "resume-challenge-counter"
    table = dynamodb.Table(table_name)
    
    #Increment the counter
    count = event["updateItem"]
    count += 1
    
    #Update the DB
    request = table.update_item(
        Key={"CounterId": "mainCounter"},
        # Expression attribute names specify placeholders for attribute names to use in your update expressions.
        ExpressionAttributeNames={
            "#visitorsNumber": "visitorsNumber",
        },
        # Expression attribute values specify placeholders for attribute values to use in your update expressions.
        ExpressionAttributeValues={
            ":id": count,
        },
        # UpdateExpression declares the updates you want to perform on your item.
        # For more details about update expressions, see https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Expressions.UpdateExpressions.html
        UpdateExpression="SET #visitorsNumber = :id",
    )
    
    #Return request status
    resp = request["ResponseMetadata"]

    return resp
