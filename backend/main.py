from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

import models
import schemas
from database import SessionLocal, engine

# 데이터베이스 테이블 생성
models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# 데이터베이스 세션 얻는 함수
# API가 호출될 때마다 이 함수가 실행되어 세션 오픈
# API 처리가 끝나면 세션을 닫음


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def read_root():
    return {"Hello": "Budget App"}

# 임시테스트


@app.get("/transactions", response_model=List[schemas.Transaction])
def read_transactions(db: Session = Depends(get_db)):
    transactions = db.query(models.Transaction).all()
    return transactions


@app.post("/transactions", response_model=schemas.Transaction)
def create_transaction(transaction: schemas.TransactionCreate, db: Session = Depends(get_db)):
    # 1. SQLAlchemy 모델 객체 생성
    db_transaction = models.Transaction(
        description=transaction.description,
        amount=transaction.amount,
        category=transaction.category,
        date=transaction.date
    )
    db.add(db_transaction)
    db.commit()  # (DB)에 저장
    db.refresh(db_transaction)  # 방금 저장한 데이터의 정보(예: 새로 생성된 id)를 다시 불러옴
    return db_transaction

# 삭제함수


@app.delete("/transactions/{transaction_id}")
def delete_transaction(transaction_id: int, db: Session = Depends(get_db)):
    transaction_to_delete = db.query(models.Transaction).filter(
        models.Transaction.id == transaction_id).first()

    # 에러처리 id없으면 ->404에러발생!
    if transaction_to_delete is None:
        raise HTTPException(status_code=404, detail="Transaction not found")

    db.delete(transaction_to_delete)
    db.commit()

    return {"message": "Transaction deleted successfully"}

# 수정함수


@app.put("/transactions/{transaction_id}", response_model=schemas.Transaction)
def update_transaction(transaction_id: int, transaction_data: schemas.TransactionCreate, db: Session = Depends(get_db)):
    transaction_to_update = db.query(models.Transaction).filter(
        models.Transaction.id == transaction_id).first()
    if transaction_to_update is None:
        raise HTTPException(status_code=404, detail="Transaction not found")

    transaction_to_update.description = transaction_data.description
    transaction_to_update.amount = transaction_data.amount
    transaction_to_update.category = transaction_data.category
    transaction_to_update.date = transaction_data.date

    db.commit()
    db.refresh(transaction_to_update)

    return transaction_to_update
