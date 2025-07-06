from sqlalchemy import Column, String, Float, Integer
from .database import Base

class Product(Base):
    __tablename__ = "products"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    price = Column(Float, nullable=False)
    category = Column(String)
    quantity = Column(Integer)

