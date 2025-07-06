import boto3
import json
import os
import logging
from fastapi import Header, HTTPException, status

logger = logging.getLogger("app")

_cached_key = None

def get_api_key(x_api_key: str = Header(...)) -> str:
    global _cached_key
    if not _cached_key:
        secret_name = os.getenv("SECRET_ID", "product-api-key")
        #localstack_host = os.environ.get("LOCALSTACK_HOST","127.0.0.1")
        region = os.getenv("AWS_REGION", "us-east-1")
        endpoint = os.getenv("LOCALSTACK_ENDPOINT")  # For local testing

        logger.info("🔐 Loading API key from Secrets Manager...")
        client = boto3.client("secretsmanager", region_name=region, endpoint_url=endpoint)
        try:
            secret_str = client.get_secret_value(SecretId=secret_name)["SecretString"]
            secret_data = json.loads(secret_str)
            _cached_key = secret_data.get("API_KEY")
            logger.info("🔐 Cached API key loaded successfully")
        except Exception as e:
            logger.error(f"❌ Failed to retrieve secret: {e}")
            raise HTTPException(status_code=500, detail="Could not load API key")

    if x_api_key != _cached_key:
        logger.warning(f"❌ Invalid API key: {x_api_key}")
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid API key")

    logger.info("✅ API key validated successfully")
    return x_api_key

