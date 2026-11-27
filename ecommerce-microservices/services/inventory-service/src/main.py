from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, EmailStr

app = FastAPI(title="inventory-service", version="1.0.0")
@app.get("/health")
def health(): return {"status": "healthy", "service": "inventory-service"}
class StockChange(BaseModel):
    product_id: int
    delta: int


stock = {1: 25, 2: 18, 3: 40, 4: 12, 5: 9, 6: 30}
@app.get("/")
def get_inventory(): return [{"product_id": k, "available": v} for k,v in stock.items()]
@app.post("/adjust")
def adjust_stock(change: StockChange):
    current = stock.get(change.product_id)
    if current is None: raise HTTPException(404, "Product not found in inventory")
    if current + change.delta < 0: raise HTTPException(409, "Insufficient stock")
    stock[change.product_id] = current + change.delta
    return {"product_id": change.product_id, "available": stock[change.product_id]}

