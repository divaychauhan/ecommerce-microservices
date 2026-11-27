from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, EmailStr

app = FastAPI(title="payment-service", version="1.0.0")
@app.get("/health")
def health(): return {"status": "healthy", "service": "payment-service"}
class PaymentRequest(BaseModel):
    order_id: int
    amount: float = Field(gt=0)
    currency: str = Field(default="USD", min_length=3, max_length=3)


payments = []
@app.post("/")
def create_payment(payment: PaymentRequest):
    # Demo only: never collect or store card numbers in this service.
    result = {"id": f"pay_{len(payments)+1:05d}", "order_id": payment.order_id, "amount": payment.amount, "currency": payment.currency, "status": "DEMO_APPROVED"}
    payments.append(result); return result
@app.get("/")
def list_payments(): return payments

