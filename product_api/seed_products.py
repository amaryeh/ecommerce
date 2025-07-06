import requests
import uuid

API_URL = "http://localhost:4566/_aws/execute-api/116dbaa3/dev/_user_request_/products"
HEADERS = {
    "x-api-key": "super-secret-value",
    "Content-Type": "application/json"
}

products = [
    {"name": "Sourdough Loaf", "price": 5.25, "category": "bread", "quantity": 10},
    {"name": "Almond Croissant", "price": 3.75, "category": "pastry", "quantity": 15},
    {"name": "Baguette", "price": 2.50, "category": "bread", "quantity": 20},
    {"name": "Cinnamon Roll", "price": 4.00, "category": "pastry", "quantity": 12},
    {"name": "Ciabatta", "price": 3.00, "category": "bread", "quantity": 8}
]

for p in products:
    res = requests.post(API_URL, headers=HEADERS, json=p)
    print(res.status_code, res.json())

