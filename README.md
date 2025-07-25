# 📄 Youlytic - YouTube 채널 분석 서비스

Ruby on Rails와 PostgreSQL을 기반으로 한 전문적인 YouTube 채널 분석 플랫폼입니다.

## 🎯 주요 기능

### 📊 채널 분석
- YouTube 채널 URL/ID/이름으로 분석 시작
- 채널 기본 정보 및 통계 수집
- 최신 영상 50-100개 분석
- 실시간 분석 진행 상황 표시

### 📈 성과 분석
- 조회수, 좋아요, 댓글 수 분석
- 참여율(Engagement Rate) 계산
- 영상 성과 분포 시각화
- 인기 영상 TOP 10 제공

### 💰 수익 추정
- 다층 CPM 모델 기반 수익 추정
- 채널 규모별 가중치 적용
- 참여도 기반 보정 계수
- 영상별/월간/연간 수익 프로젝션

### 📑 리포트 생성
- PDF 형태 전문 리포트
- CSV 데이터 내보내기
- 퍼머링크를 통한 공유 기능
- 대시보드에서 분석 히스토리 관리

## 🏗️ 기술 스택

- **Backend**: Ruby on Rails 7.x
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq + Redis
- **Frontend**: Turbo + Stimulus + TailwindCSS
- **Charts**: Chart.js
- **API**: YouTube Data API v3
- **PDF**: WickedPDF

## 📋 설치 및 실행

### 1. 의존성 설치
```bash
bundle install
```

### 2. 환경 변수 설정
```bash
cp .env.example .env
# .env 파일에서 다음 값들을 설정하세요:
# - YOUTUBE_API_KEY: YouTube Data API v3 키
# - DATABASE_USERNAME, DATABASE_PASSWORD: PostgreSQL 계정 정보
# - REDIS_URL: Redis 서버 URL
```

### 3. 데이터베이스 설정
```bash
rails db:create
rails db:migrate
```

### 4. Redis 서버 시작
```bash
redis-server
```

### 5. Sidekiq 시작 (백그라운드 작업)
```bash
bundle exec sidekiq
```

### 6. Rails 서버 시작
```bash
rails server
```

애플리케이션이 `http://localhost:3000`에서 실행됩니다.

## 🔑 YouTube API 설정

1. [Google Cloud Console](https://console.cloud.google.com/)에서 프로젝트 생성
2. YouTube Data API v3 활성화
3. API 키 생성 및 `.env` 파일에 설정
4. 일일 할당량 확인 (기본 10,000 units)

## 📊 데이터베이스 구조

### 핵심 테이블
- `users`: 사용자 정보 및 구독 관리
- `channels`: YouTube 채널 정보
- `videos`: 영상 상세 정보 및 통계
- `analysis_reports`: 분석 리포트 및 결과
- `channel_snapshots`: 채널 통계 스냅샷 (시계열 데이터)

## 🚀 사용법

### 채널 분석하기
1. 홈페이지에서 YouTube 채널 URL, ID, 또는 채널명 입력
2. "분석 시작" 버튼 클릭
3. 분석 진행 상황 확인 (실시간 새로고침)
4. 완료된 분석 결과 확인

### 결과 활용하기
- **PDF 다운로드**: 전문적인 분석 리포트
- **CSV 내보내기**: 상세 데이터 분석용
- **퍼머링크 공유**: 24시간 유효한 공유 링크
- **대시보드**: 분석 히스토리 및 즐겨찾기 관리

## 🔐 보안 및 제한사항

### API 할당량 관리
- 비회원: 일 3회 분석 제한
- 회원: 추가 할당량 및 히스토리 저장
- 프리미엄: 무제한 분석 + 고급 기능

### 데이터 보호
- GDPR 및 개인정보보호법 준수
- API Rate Limiting 적용
- 보안 헤더 및 CORS 설정

## 🎨 주요 화면

### 홈페이지
- 채널 분석 입력 폼
- 최근 분석 결과 미리보기
- 인기 채널 갤러리

### 분석 결과 페이지
- 채널 기본 정보 카드
- 핵심 지표 대시보드
- 조회수 분포 차트
- 성과 트렌드 그래프
- 인기 영상 테이블
- 콘텐츠 인사이트

### 사용자 대시보드
- 분석 히스토리
- 즐겨찾기 채널
- 사용량 통계

## 🔧 개발 도구

### Sidekiq 모니터링
- 개발 환경: `http://localhost:3000/sidekiq`
- 백그라운드 작업 상태 확인

### API 엔드포인트
```
GET /api/v1/channels/:id
POST /api/v1/channels/analyze
GET /api/v1/analysis_reports/:id
```

## 📈 성능 최적화

### 캐싱 전략
- 채널 정보: 6시간 캐시
- 영상 통계: 1시간 캐시
- API 응답: Redis 기반 캐싱

### 데이터베이스 최적화
- 인덱스 최적화 적용
- N+1 쿼리 방지
- 페이지네이션 구현

## 🚀 배포

### Production 환경 설정
```bash
RAILS_ENV=production bundle exec rails assets:precompile
RAILS_ENV=production bundle exec rails db:migrate
```

### 환경 변수 (Production)
- `SECRET_KEY_BASE`: Rails 시크릿 키
- `DATABASE_URL`: PostgreSQL 연결 URL
- `REDIS_URL`: Redis 연결 URL
- `YOUTUBE_API_KEY`: YouTube API 키

## 📞 지원

문제가 발생하거나 기능 요청이 있으시면 GitHub Issues를 통해 연락해 주세요.

---

© 2024 Youlytic. YouTube 채널 분석의 새로운 기준.