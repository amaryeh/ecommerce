import logging
import sys
import uuid
from fastapi import FastAPI, HTTPException, Depends, Request, Response
from sqlalchemy.orm import Session
from fastapi.responses import JSONResponse
from mangum import Mangum

from app.schema import Product, ProductCreate
from app.models import Product as DBProduct
from app.auth import get_api_key
from app.dependencies import rate_limiter
from app.deps import get_db

# ── Logging Setup ─────────────────────────────────────
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger("app")

# ── App Config ────────────────────────────────────────
app = FastAPI(root_path="/dev")

@app.on_event("startup")
def on_startup():
    from app.database import Base, engine
    from app.models import Product
    Base.metadata.create_all(bind=engine)


# ── Middleware: Log Incoming Path ─────────────────────
@app.middleware("http")
async def log_path(request: Request, call_next):
    logger.info(f"Incoming path: {request.url.path}")
    return await call_next(request)


# ── Exception Handling ────────────────────────────────
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail},
        headers={"Content-Type": "application/json"},
    )

#support CORS headers
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or restrict to your frontend origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Routes ────────────────────────────────────────────
@app.get("/products", response_model=list[Product])
def get_all_products(key: str = Depends(get_api_key), db: Session = Depends(get_db)):
    products = db.query(DBProduct).all()
    logger.info(f"Returned all products ({len(products)})")
    return products


@app.get("/products/{id}", response_model=Product)
def get_product(id: str, key: str = Depends(get_api_key), db: Session = Depends(get_db)):
    product = db.query(DBProduct).get(id)
    if not product:
        raise HTTPException(404, detail="Product not found")
    return product


@app.post(
    "/products",
    response_model=Product,
    status_code=201,
    dependencies=[Depends(rate_limiter)],
)
def create_product(product: ProductCreate, key: str = Depends(get_api_key), db: Session = Depends(get_db)):
    pid = str(uuid.uuid4())
    db_product = DBProduct(id=pid, **product.dict())
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    logger.info(f"Created product {pid}")
    return db_product


@app.put("/products/{id}", response_model=Product)
def update_product(id: str, product: ProductCreate, key: str = Depends(get_api_key), db: Session = Depends(get_db)):
    db_product = db.query(DBProduct).get(id)
    if not db_product:
        raise HTTPException(404, detail="Product not found")
    for field, value in product.dict().items():
        setattr(db_product, field, value)
    db.commit()
    db.refresh(db_product)
    logger.info(f"Updated product {id}")
    return db_product


@app.delete("/products/{id}", status_code=204)
def delete_product(id: str, key: str = Depends(get_api_key), db: Session = Depends(get_db)):
    db_product = db.query(DBProduct).get(id)
    if not db_product:
        raise HTTPException(404, detail="Product not found")
    db.delete(db_product)
    db.commit()
    logger.info(f"Deleted product {id}")
    return Response(status_code=204)


# ── Lambda Handler ────────────────────────────────────
handler = Mangum(app)

