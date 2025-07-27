import json
import uuid
from datetime import datetime

def access_request_handler(event, context):
    try:
        # Parse the request body
        body = json.loads(event.get('body', '{}'))
        
        # Extract required fields (don't require request_id as we'll generate it)
        user_id = body.get('user_id')
        resource = body.get('resource')
        justification = body.get('justification', '')
        duration_hours = body.get('duration_hours', 1)
        
        # Validate required fields
        if not user_id or not resource:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'Missing required fields: user_id and resource are required'
                })
            }
        
        # Generate a unique request ID
        request_id = str(uuid.uuid4())
        
        # Create timestamp
        timestamp = datetime.utcnow().isoformat()
        
        print(f"Creating access request - User: {user_id}, Resource: {resource}, Request ID: {request_id}")
        
        # Here you would typically:
        # 1. Save the request to DynamoDB with status PENDING_MANUAL_REVIEW
        # 2. Send notification to manager
        # 3. Check if policy template exists (as shown in your diagram)
        
        # For now, we'll just return success with the generated request_id
        response_data = {
            'message': 'Access request submitted successfully',
            'request_id': request_id,
            'user_id': user_id,
            'resource': resource,
            'justification': justification,
            'duration_hours': duration_hours,
            'status': 'PENDING_MANUAL_REVIEW',
            'created_at': timestamp
        }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps(response_data)
        }
        
    except json.JSONDecodeError:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Invalid JSON in request body'
            })
        }
    except Exception as e:
        print(f"Error processing access request: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Internal server error'
            })
        }