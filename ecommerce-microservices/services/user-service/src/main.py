from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, EmailStr

app = FastAPI(title="user-service", version="1.0.0")
@app.get("/health")
def health(): return {"status": "healthy", "service": "user-service"}
class UserCreate(BaseModel):
    name: str = Field(min_length=2, max_length=80)
    email: EmailStr


users = [{"id": 1, "name": "Alex Morgan", "email": "alex@example.com"}]
@app.get("/")
def list_users(): return users
@app.post("/")
def create_user(user: UserCreate):
    if any(u["email"] == user.email for u in users): raise HTTPException(409, "Email already exists")
    item = {"id": max([u["id"] for u in users], default=0)+1, **user.model_dump()}
    users.append(item); return item

