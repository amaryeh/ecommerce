import boto3
import json
import os


def handler(event, context):
    secret_id = os.environ.get("SECRET_ID", "ecommerce-db-credentials")
    localstack_host = os.environ.get("LOCALSTACK_HOST", "127.0.0.1")
    endpoint_url = f"http://{localstack_host}:4566"

    try:
        client = boto3.client(
            "secretsmanager",
            region_name="us-east-1",
            endpoint_url=endpoint_url
        )

        secret_string = client.get_secret_value(SecretId=secret_id).get("SecretString", "{}")
        secret = json.loads(secret_string)
        username = secret.get("username", "unknown")

        return {
            "statusCode": 200,
            "body": f"👋 Hello from {username}'s secure Lambda!"
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Internal error: {str(e)}"
        }
