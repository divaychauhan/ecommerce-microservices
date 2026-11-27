from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, EmailStr

app = FastAPI(title="order-service", version="1.0.0")
@app.get("/health")
def health(): return {"status": "healthy", "service": "order-service"}
class OrderLine(BaseModel):
    product_id: int
    name: str
    price: float = Field(gt=0)
    quantity: int = Field(ge=1, le=20)
class OrderCreate(BaseModel):
    customer_email: EmailStr
    items: list[OrderLine] = Field(min_length=1)


orders = []
@app.get("/")
def list_orders(): return orders
@app.post("/")
def create_order(order: OrderCreate):
    item = {"id": len(orders)+1001, "customer_email": order.customer_email, "items": [x.model_dump() for x in order.items], "status": "PLACED", "total": round(sum(x.price*x.quantity for x in order.items), 2)}
    orders.append(item); return item

