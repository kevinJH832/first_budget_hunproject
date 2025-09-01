# 가계부 앱 (Budget App)
> Flutter + FastAPI를 이용한 개인 가계부 관리 앱

## 📱 주요 기능
- 지출 내역 관리
- 카테고리별 분류
- 실시간 데이터 동기화

## 🛠 기술 스택
- Frontend: Flutter (Dart)
- Backend: FastAPI (Python)
- Database: SQLite

### 1일차 (2025.08.31)
**🎯 목표** : Flutter + FastAPI 가계부 앱 기본 구조 구성
- FastAPI 백엔드 구조 완성 (models, schemas, database)
- CRUD API 엔드포인트 구현 (GET, POST, PUT, DELETE)
- Git 저장소 정리 및 GitHub 업로드

### 2일차 (2025.09.01)
**🎯 목표** : Flutter 프론트엔드 기본 UI 구현 및 백엔드 연동
- '내역 추가' 화면 기능 구현
- 실시간 숫자 포맷팅(intl 패키지)이 적용된 금액 입력 TextField 구현
- ListTile과 CupertinoDatePicker를 이용한 날짜 및 카테고리 선택 기능 구현
- '저장' 버튼 클릭 시 POST /transactions API를 호출하여 백엔드 DB에 데이터 저장 기능 연결
- 실시간 UI 업데이트: GlobalKey를 활용하여 내역 저장 후 '오늘' 탭의 목록이 자동으로 새로고침되는 기능 구현
- '+' 버튼 ui 구현 