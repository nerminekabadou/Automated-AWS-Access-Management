import datetime
import json
import uuid
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')

access_requests_table = dynamodb.Table(os.environ.get("ACCESS_REQUESTS_TABLE", "AccessRequestsTable"))
policy_templates_table = dynamodb.Table(os.environ.get("POLICY_TEMPLATES_TABLE", "PolicyTemplatesTable"))

ses = boto3.client('ses')

def error_response(status_code, message):
    return {
        'statusCode': status_code,
        'body': json.dumps({'error': message})
    }

def success_response(response_data):
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps(response_data)
    }

def access_request_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        user_id = body.get('user_id')
        resource = body.get('resource')
        justification = body.get('justification', '')
        duration_hours = body.get('duration_hours', 1)
        
        if not user_id or not resource:
            return error_response(400, 'Missing required fields: user_id and resource are required')
        
        request_id = str(uuid.uuid4())
        timestamp = datetime.utcnow().isoformat()
        
        # Check if policy template exists
        try:
            response = policy_templates_table.get_item(Key={'resource': resource})
            if 'Item' in response:
                status = 'PENDING_APPROVAL'
            else:
                status = 'PENDING_MANUAL_REVIEW'
        except ClientError as e:
            print(f"DynamoDB error: {e}")
            status = 'PENDING_MANUAL_REVIEW'
        
        # Save to DynamoDB
        try:
            access_requests_table.put_item(
                Item={
                    'request_id': request_id,
                    'user_id': user_id,
                    'resource': resource,
                    'justification': justification,
                    'duration_hours': duration_hours,
                    'status': status,
                    'created_at': timestamp,
                    'updated_at': timestamp
                }
            )
        except ClientError as e:
            print(f"DynamoDB error: {e}")
            return error_response(500, 'Failed to save access request')
        
        # Send notification
        if status == 'PENDING_APPROVAL':
            send_approval_notification(request_id, user_id, resource)
        
        response_data = {
            'message': 'Access request submitted successfully',
            'request_id': request_id,
            'status': status,
            # ... other fields
        }
        
        return success_response(response_data)
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return error_response(500, 'Internal server error')

import os

def send_approval_notification(request_id, user_id, resource):
    try:
        # Replace with actual manager email
        manager_email = "kabadounermine@gmail.com"
        
        api_gateway_url = os.environ.get('API_GATEWAY_URL', 'api.example.com')
        approval_url = f"https://{api_gateway_url}/approve/{request_id}"
        
        ses.send_email(
            Source='noreply@yourdomain.com',
            Destination={'ToAddresses': [manager_email]},
            Message={
                'Subject': {'Data': f'Access Request Approval Needed for {resource}'},
                'Body': {
                    'Text': {
                        'Data': f"""Hello Manager,
                        
A new access request requires your approval:
- User: {user_id}
- Resource: {resource}
                        
Please review and approve: {approval_url}
"""
                    }
                }
            }
        )
    except ClientError as e:
        print(f"SES error: {e}")