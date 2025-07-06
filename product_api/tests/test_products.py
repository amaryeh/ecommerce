from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)
headers = {"X-API-Key": "secret123"}

def test_create_product():
    payload = {"name": "Test Product", "price": 9.99, "quantity": 5}
    res = client.post("/products", json=payload, headers=headers)
    assert res.status_code == 201
    data = res.json()
    assert data["name"] == payload["name"]
    assert "id" in data

def test_get_products():
    res = client.get("/products", headers=headers)
    assert res.status_code == 200
    assert isinstance(res.json(), list)

def test_get_product_by_id():
    # First, create
    payload = {"name": "Single View", "price": 2.99, "quantity": 1}
    create = client.post("/products", json=payload, headers=headers)
    pid = create.json()["id"]

    # Now, retrieve by ID
    res = client.get(f"/products/{pid}", headers=headers)
    assert res.status_code == 200
    assert res.json()["id"] == pid

def test_update_product():
    # Create
    payload = {"name": "Old Name", "price": 1.00, "quantity": 1}
    create = client.post("/products", json=payload, headers=headers)
    pid = create.json()["id"]

    # Update
    updated = {"name": "Updated Name", "price": 3.14, "quantity": 7}
    res = client.put(f"/products/{pid}", json=updated, headers=headers)
    assert res.status_code == 200
    assert res.json()["name"] == "Updated Name"

def test_delete_product():
    # Create
    payload = {"name": "To Delete", "price": 0.99, "quantity": 1}
    create = client.post("/products", json=payload, headers=headers)
    pid = create.json()["id"]

    # Delete
    delete = client.delete(f"/products/{pid}", headers=headers)
    assert delete.status_code == 204

    # Confirm gone
    get = client.get(f"/products/{pid}", headers=headers)
    assert get.status_code == 404
# Test for invalid input
def test_create_product_invalid_data():
    # Missing 'name' and invalid 'price'
    payload = {"price": -1, "quantity": -5}
    res = client.post("/products", json=payload, headers=headers)
    assert res.status_code == 422
    data = res.json()
    assert "detail" in data
