# Render 배포 가이드

## 1. Render 계정 및 서비스 생성
1. https://render.com 접속 후 GitHub으로 로그인
2. "New +" → "Web Service" 선택
3. GitHub 저장소 `youlytic2` 연결

## 2. 배포 설정
### Build & Deploy 설정:
- **Environment**: `Docker`
- **Dockerfile Path**: `Dockerfile.render`
- **Build Command**: (비워둠 - Dockerfile에서 처리)
- **Start Command**: (비워둠 - Dockerfile에서 처리)

### 환경 변수 설정:
```
RAILS_ENV=production
SECRET_KEY_BASE=<자동 생성>
DATABASE_URL=<PostgreSQL 연결 후 자동 설정>

# OAuth 설정 (테스트용)
GOOGLE_CLIENT_ID=test_google_client_id
GOOGLE_CLIENT_SECRET=test_google_client_secret
KAKAO_CLIENT_ID=test_kakao_client_id
KAKAO_CLIENT_SECRET=test_kakao_client_secret
NAVER_CLIENT_ID=test_naver_client_id
NAVER_CLIENT_SECRET=test_naver_client_secret
```

## 3. 데이터베이스 추가
1. Render 대시보드에서 "New +" → "PostgreSQL" 선택
2. 데이터베이스 생성 후 `DATABASE_URL`을 웹 서비스 환경 변수에 추가

## 4. 배포 후 확인
- Render가 제공하는 URL (예: `https://youlytic2.onrender.com`)
- 로그에서 Rails 서버 정상 시작 확인

## 5. OAuth 콜백 URL 업데이트
배포 성공 후 각 OAuth 제공자에서 콜백 URL 업데이트:
- Google: `https://your-app.onrender.com/users/auth/google_oauth2/callback`
- Kakao: `https://your-app.onrender.com/users/auth/kakao/callback`
- Naver: `https://your-app.onrender.com/users/auth/naver/callback`

## Render의 장점
- Rails 배포에 최적화
- 자동 SSL 인증서
- GitHub 연동 자동 배포
- PostgreSQL 통합 지원
- Railway보다 안정적인 Rails 환경