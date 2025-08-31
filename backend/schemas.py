from pydantic import BaseModel


# Transaction 모델의 기본 형태
class TransactionBase(BaseModel):
    description: str
    amount: int
    category: str
    date: str

# Transaction 생성 시 사용할 모델


class TransactionCreate(TransactionBase):
    pass

# Transaction 조회 시 사용할 모델


class Transaction(TransactionBase):
    id: int

    class Config:
        orm_mode = True
