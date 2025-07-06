from fastapi import Request, HTTPException
import time

rate_store = {}

def rate_limiter(request: Request):
    ip = request.client.host
    now = time.time()
    window = 60  # seconds
    max_requests = 10

    rate_store.setdefault(ip, [])
    rate_store[ip] = [t for t in rate_store[ip] if now - t < window]

    if len(rate_store[ip]) >= max_requests:
        raise HTTPException(status_code=429, detail="Too many requests")

    rate_store[ip].append(now)
