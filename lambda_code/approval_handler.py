import json

def approval_handler(event, context):
    try:
        # Extract request_id from path parameters
        path_parameters = event.get('pathParameters', {})
        request_id = path_parameters.get('request_id') if path_parameters else None
        
        # Extract decision from request body
        body = json.loads(event.get('body', '{}'))
        decision = body.get('decision')
        
        if not request_id:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({'error': 'Missing request_id in path'})
            }
            
        if not decision:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({'error': 'Missing decision in request body'})
            }
        
        # Validate decision value
        if decision not in ['approved', 'rejected']:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({'error': 'Decision must be either "approved" or "rejected"'})
            }
        
        print(f"Request ID: {request_id}, Decision: {decision}")
        
        # Here you would typically:
        # 1. Update the request status in DynamoDB
        # 2. Send notifications if needed
        # 3. Perform any other business logic
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'message': f"Request {request_id} has been {decision}.",
                'request_id': request_id,
                'decision': decision
            })
        }
        
    except json.JSONDecodeError:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': 'Invalid JSON in request body'})
        }
    except Exception as e:
        print(f"Error processing approval: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': 'Internal server error'})
        }