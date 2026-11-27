from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, EmailStr

app = FastAPI(title="notification-service", version="1.0.0")
@app.get("/health")
def health(): return {"status": "healthy", "service": "notification-service"}
class Notification(BaseModel):
    recipient: EmailStr
    subject: str = Field(min_length=1, max_length=120)
    message: str = Field(min_length=1, max_length=2000)


notifications = []
@app.get("/")
def list_notifications(): return notifications
@app.post("/")
def send_notification(note: Notification):
    item = {"id": len(notifications)+1, **note.model_dump(), "status": "QUEUED_DEMO"}
    notifications.append(item); return item

