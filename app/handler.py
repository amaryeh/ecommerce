import boto3
import json
import os

def handler(event, context):
    secret_id = os.environ.get("SECRET_ID", "ecommerce-db-credentials")
    endpoint_url = os.environ.get("LOCALSTACK_ENDPOINT", "http://localhost:4566")
    region = os.environ.get("AWS_REGION", "us-east-1")

    try:
        print("🔎 Initializing boto3 client for Secrets Manager...")
        client = boto3.client("secretsmanager", region_name=region, endpoint_url=endpoint_url)

        print("📋 Listing secrets to confirm connectivity...")
        available = client.list_secrets()
        print(f"✅ Secrets visible: {[s['Name'] for s in available.get('SecretList', [])]}")

        print(f"🔐 Fetching secret: {secret_id}")
        response = client.get_secret_value(SecretId=secret_id)
        secret = json.loads(response.get("SecretString", "{}"))
        username = secret.get("username", "unknown")

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "message": f"👋 Hello from {username}'s secure Lambda!"
            })
        }

    except client.exceptions.ResourceNotFoundException:
        return {
            "statusCode": 404,
            "body": json.dumps({"error": f"Secret '{secret_id}' not found"})
        }

    except Exception as e:
        print(f"❌ Internal failure: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": f"Internal error: {str(e)}"})
        }

