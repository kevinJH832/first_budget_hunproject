from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional

from fastapi.middleware.cors import CORSMiddleware  # 웹앱
import models
import schemas
from database import SessionLocal, engine

# 데이터베이스 테이블 생성
models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# 데이터베이스 세션 얻는 함수
# API가 호출될 때마다 이 함수가 실행되어 세션 오픈
# API 처리가 끝나면 세션을 닫음

origins = [
    "https://monumental-souffle-177145.netlify.app",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],  # 모든 메소드 허용
    allow_headers=["*"],  # 모든 헤더 허용
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def read_root():
    return {"Hello": "Budget App"}


# 일별조회
@app.get("/transactions", response_model=List[schemas.Transaction])
def read_transactions(date: Optional[str] = None, db: Session = Depends(get_db)):
    if date:
        transactions = db.query(models.Transaction).filter(
            models.Transaction.date == date).all()
    else:
        transactions = db.query(models.Transaction).all()
    return transactions


# 월별조회
@app.get("/transactions/monthly", response_model=List[schemas.Transaction])
def read_monthly_transactions(year: int, month: int, db: Session = Depends(get_db)):
    month_str = f"{month:02d}"  # 1월이면 01 로 대치
    start_date = f"{year}-{month_str}-01"

    # 12월은 내년 1월인거인지
    if month == 12:
        end_date = f"{year + 1}-01-01"
    else:
        end_date = f"{year}-{month + 1:02d}-01"

    transactions = db.query(models.Transaction).filter(
        models.Transaction.date >= start_date,
        models.Transaction.date < end_date
    ).all()

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
