import json
import boto3
import base64
import os
from datetime import datetime

s3_client = boto3.client('s3')
BUCKET_NAME = os.environ.get('UPLOAD_BUCKET_NAME')

def lambda_handler(event, context):
    try:
        if BUCKET_NAME is None:
            raise ValueError("UPLOAD_BUCKET_NAME environment variable not set.")

        # API Gateway HTTP API sends the body as a base64 encoded string
        # when the content type is not application/json
        file_content = base64.b64decode(event['body'])
        
        # Extract filename from headers if available, otherwise generate one
        headers = event.get('headers', {})
        content_disposition = headers.get('content-disposition')
        filename = "default_filename.txt"
        if content_disposition:
            parts = content_disposition.split(';')
            for part in parts:
                if 'filename=' in part:
                    filename = part.split('=')[1].strip('"')
        
        timestamp = datetime.utcnow().strftime('%Y-%m-%d-%H-%M-%S')
        s3_key = f"uploads/{timestamp}-{filename}"

        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=s3_key,
            Body=file_content
        )

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'File uploaded successfully!',
                'bucket': BUCKET_NAME,
                'key': s3_key
            })
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

