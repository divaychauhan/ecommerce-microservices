from fastapi import FastAPI, HTTPException

app = FastAPI(title="product-service", version="1.0.0")
@app.get("/health")
def health(): return {"status": "healthy", "service": "product-service"}


products = [
 {"id": 1, "name": "Minimal Sneakers", "category": "Fashion", "price": 79.0, "emoji": "👟", "description": "Everyday comfort, clean design."},
 {"id": 2, "name": "Studio Headphones", "category": "Electronics", "price": 129.0, "emoji": "🎧", "description": "Immersive sound for focused days."},
 {"id": 3, "name": "Everyday Backpack", "category": "Accessories", "price": 59.0, "emoji": "🎒", "description": "Room for everything that matters."},
 {"id": 4, "name": "Ceramic Pour-over Set", "category": "Home", "price": 42.0, "emoji": "☕", "description": "A calmer morning ritual."},
 {"id": 5, "name": "Smart Watch", "category": "Electronics", "price": 189.0, "emoji": "⌚", "description": "A little more insight every day."},
 {"id": 6, "name": "Cotton Overshirt", "category": "Fashion", "price": 68.0, "emoji": "🧥", "description": "An easy layer for every season."}
]
@app.get("/")
def list_products(): return products
@app.get("/{product_id}")
def get_product(product_id: int):
    item = next((p for p in products if p["id"] == product_id), None)
    if not item: raise HTTPException(404, "Product not found")
    return item

