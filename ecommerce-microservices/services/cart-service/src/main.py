from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, EmailStr

app = FastAPI(title="cart-service", version="1.0.0")
@app.get("/health")
def health(): return {"status": "healthy", "service": "cart-service"}
class CartItem(BaseModel):
    product_id: int
    name: str
    price: float = Field(gt=0)
    quantity: int = Field(default=1, ge=1, le=20)


cart = []
@app.get("/")
def get_cart(): return {"items": cart, "total": round(sum(x["price"]*x["quantity"] for x in cart), 2)}
@app.post("/items")
def add_item(item: CartItem):
    existing = next((x for x in cart if x["product_id"] == item.product_id), None)
    if existing: existing["quantity"] += item.quantity
    else: cart.append(item.model_dump())
    return {"items": cart}
@app.delete("/")
def clear_cart(): cart.clear(); return {"message": "Cart cleared"}

