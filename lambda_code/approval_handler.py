import json
import boto3
import os

# Initialiser le client DynamoDB
dynamodb = boto3.resource('dynamodb')

access_requests_table = dynamodb.Table(os.environ.get("ACCESS_REQUESTS_TABLE", "AccessRequestsTable"))
policy_templates_table = dynamodb.Table(os.environ.get("POLICY_TEMPLATES_TABLE", "PolicyTemplatesTable"))

def approval_handler(event, context):
    try:
        # Corps du message (JSON)
        body = json.loads(event.get('body', '{}'))

        request_id = body.get('request_id')
        approval = body.get('approval')  # true or false

        if not request_id or approval is None:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'request_id and approval are required'})
            }

        # Déterminer le nouveau statut
        new_status = "approved" if approval else "rejected"

        # Mettre à jour l'entrée dans DynamoDB
        response = table.update_item(
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
