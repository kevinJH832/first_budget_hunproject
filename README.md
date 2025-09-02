# 💸 나의 가계부 앱 (My Budget App)

> Flutter와 FastAPI를 이용해 개발하는 개인 가계부 관리 앱 프로젝트입니다.
> Gemini와 Claude AI의 도움을 받으며 학습과 개발을 동시에 진행합니다.

---

## 📱 주요 기능

- **실시간 CRUD**: 백엔드 DB와 연동하여 거래 내역을 실시간으로 조회, 추가, 수정, 삭제합니다.
- **카테고리별 분류**: 지출 내역을 카테고리별로 나누어 관리합니다.
- **날짜별 조회**: '오늘' 탭과 '캘린더' 탭을 통해 특정 날짜의 지출 내역을 필터링합니다.

---

## 🛠️ 기술 스택

- **Frontend**: Flutter (Dart)
- **Backend**: FastAPI (Python)
- **Database**: SQLite

---

## 🚀 개발 일지

### Day 1 (2025.08.31) - 백엔드 기초 공사
- **목표**: FastAPI 백엔드 기본 구조 완성
- FastAPI 프로젝트 구조 설계 (`models`, `schemas`, `database`)
- CRUD API 엔드포인트 전체 구현 (`GET`, `POST`, `PUT`, `DELETE`)
- Git 저장소 초기화 및 GitHub 업로드

### Day 2 (2025.09.01) - 프론트엔드 UI 구현
- **목표**: Flutter 프론트엔드 기본 UI 및 백엔드 연동
- '내역 추가' 화면 UI 및 기능 구현 (`ModalBottomSheet`)
- `intl` 패키지를 이용한 실시간 숫자 포맷팅 적용
- `CupertinoDatePicker`를 활용한 네이티브 날짜 선택 기능 구현
- `GlobalKey`를 이용한 목록 자동 새로고침 기능 구현

### Day 3 (2025.09.02) - '오늘' 탭 완성 및 고도화
- **목표**: '오늘' 탭 기능 완성 및 UI/UX 개선
- 날짜 필터링 기능 구현 (Full-stack)
    - 백엔드 API에 날짜 쿼리 파라미터 기능 추가
    - 프론트엔드에서 '오늘' 날짜 기준으로 데이터 요청
- '오늘' 탭 UI 전면 개편
    - iOS 스타일의 날짜/총액 표시 카드 UI 적용
    - `Card` 기반의 커스텀 목록 아이템 디자인
- 스와이프 액션 메뉴 도입 (`flutter_slidable`)
- '거래 내역 수정(Update)' 기능 완성 및 연동