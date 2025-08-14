import json
import boto3
import os

# Initialiser le client DynamoDB
dynamodb = boto3.resource('dynamodb')

access_requests_table = dynamodb.Table(os.environ.get("ACCESS_REQUESTS_TABLE", "AccessRequestsTable"))
policy_templates_table = dynamodb.Table(os.environ.get("POLICY_TEMPLATES_TABLE", "PolicyTemplatesTable"))

def approval_handler(event, context):
    try:
        # Get request_id from path parameter
        request_id = event.get('pathParameters', {}).get('request_id')
        if not request_id:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'request_id is required'})
            }

        # Always approve (GET link = approve)
        new_status = "APPROVED"

        # Update DynamoDB
        response = access_requests_table.update_item(
            Key={'request_id': request_id},
            UpdateExpression="SET #s = :val",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={":val": new_status},
            ReturnValues="UPDATED_NEW"
        )

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Request {request_id} has been {new_status}.',
                'updatedAttributes': response.get('Attributes')
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }