# Fly.io 배포 가이드

## 무료 티어 정보
- **3개 앱** 무료
- **256MB RAM** per app
- **1GB 스토리지**
- **160GB 네트워크/월**

## 1. Fly.io CLI 설치
```bash
# macOS
brew install flyctl

# Windows
iwr https://fly.io/install.ps1 -useb | iex

# Linux
curl -L https://fly.io/install.sh | sh
```

## 2. 계정 생성 및 로그인
```bash
flyctl auth signup
flyctl auth login
```

## 3. 앱 생성 및 배포
```bash
# 프로젝트 디렉토리에서
flyctl launch

# 설정 옵션:
# - App name: youlytic2 (또는 원하는 이름)
# - Region: nrt (Tokyo)
# - PostgreSQL: Yes
# - Redis: No (나중에 필요하면 추가)
```

## 4. 환경 변수 설정
```bash
flyctl secrets set RAILS_ENV=production
flyctl secrets set SECRET_KEY_BASE=$(openssl rand -hex 64)
flyctl secrets set GOOGLE_CLIENT_ID=test_google_client_id
flyctl secrets set GOOGLE_CLIENT_SECRET=test_google_client_secret
flyctl secrets set KAKAO_CLIENT_ID=test_kakao_client_id
flyctl secrets set KAKAO_CLIENT_SECRET=test_kakao_client_secret
flyctl secrets set NAVER_CLIENT_ID=test_naver_client_id
flyctl secrets set NAVER_CLIENT_SECRET=test_naver_client_secret
```

## 5. 배포
```bash
flyctl deploy --dockerfile Dockerfile.fly
```

## 6. 앱 접속
```bash
flyctl open
# 또는 https://youlytic2.fly.dev
```

## 장점
- **완전 무료** (제한 내에서)
- **Rails 친화적**
- **PostgreSQL 무료 포함**
- **빠른 글로벌 배포**
- **자동 스케일링**

## 단점
- **메모리 제한** (256MB)
- **CLI 필수** (웹 대시보드 제한적)

이게 가장 좋은 무료 옵션일 것 같습니다!