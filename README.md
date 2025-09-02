# 가계부 앱 (Budget App)
> Flutter + FastAPI를 이용한 개인 가계부 관리 앱
> 제미나이 + Claude 를 통해서 배우면서 작업!!

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

### 3일차 (2025.09.02)
**🎯 목표** : '오늘' 탭 기능 완성 및 UI/UX 고도화
- 날짜 필터링 기능 구현 (Full-stack)
- 백엔드 GET /transactions API를 특정 날짜로 조회할 수 있도록 쿼리 파라미터 기능 추가
- 프론트엔드 api_service를 수정하여, '오늘' 탭에서는 오늘 날짜의 데이터만 요청하도록 변경.

- '오늘' 탭 UI 전면 개편
- 화면 상단에 iOS 캘린더 스타일의 날짜 및 총 지출액 표시 카드 UI 구현
- 단순 ListTile 목록을 Card 기반의 커스텀 위젯으로 변경하여 가시성 및 디자인 개선.

- 스와이프 액션 메뉴 구현
- flutter_slidable 패키지를 도입하여, 목록 아이템을 스와이프 시 '수정' 및 '삭제' 버튼이 나타나는 네이티브 앱과 유사한 UX 구현

- '거래 내역 수정(Update)' 기능 완성
- AddTransactionScreen 위젯을 재활용하여 '수정 모드'를 지원하도록 업그레이드
- 목록 아이템의 '수정' 버튼과 연동하여 기존 데이터를 수정하고 백엔드 DB에 반영하는 기능 완성
