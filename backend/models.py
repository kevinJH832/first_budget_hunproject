from sqlalchemy import Column, Integer, String
from database import Base

# 테이블 만들기


class Transaction(Base):
    __tablename__ = "transactions"
    id = Column(Integer, primary_key=True, index=True)  # 식별자 ID (기본키, 인덱스)
    description = Column(String, index=True)  # 지출 설명 (인덱스)
    amount = Column(Integer)  # 금액
    category = Column(String)  # 카테고리
    date = Column(String)  # 날짜
