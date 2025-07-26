# Railway 배포 가이드

## 1. Railway 프로젝트 생성
1. https://railway.app 접속 후 GitHub으로 로그인
2. "New Project" 클릭
3. "Deploy from GitHub repo" 선택
4. `kangtae4/youlytic2` 저장소 선택

## 2. 환경 변수 설정
Railway 대시보드 > Variables 탭에서 다음 환경 변수들을 설정:

### 필수 환경 변수
```bash
# Rails (기본값으로도 작동)
RAILS_ENV=production
SECRET_KEY_BASE=<Railway에서 자동 생성 또는 비워둬도 됨>

# Database (Railway PostgreSQL 플러그인 추가 후 자동 설정)
DATABASE_URL=<Railway PostgreSQL 플러그인에서 자동 설정>

# OAuth 설정 (테스트용 - 실제 서비스 시 실제 값으로 교체)
GOOGLE_CLIENT_ID=test_google_client_id
GOOGLE_CLIENT_SECRET=test_google_client_secret
KAKAO_CLIENT_ID=test_kakao_client_id
KAKAO_CLIENT_SECRET=test_kakao_client_secret
NAVER_CLIENT_ID=test_naver_client_id
NAVER_CLIENT_SECRET=test_naver_client_secret

# YouTube API (기존 키 사용)
YOUTUBE_API_KEY=AIzaSyBRtIjCIBjklW6mBxYpeT8VBhoebWuvA9c

# Redis (Railway Redis 플러그인 추가 후 자동 설정)
REDIS_URL=<Railway Redis 플러그인에서 자동 설정>
```

### 최소 필수 설정 (서버 시작용)
1. PostgreSQL 플러그인만 추가하면 기본 실행 가능
2. OAuth는 테스트 값으로 설정해도 서버는 시작됨
3. Redis 플러그인은 백그라운드 작업용 (선택사항)

## 3. 플러그인 추가
Railway 대시보드에서 다음 플러그인들을 추가:
- PostgreSQL
- Redis

## 4. OAuth Callback URL 업데이트
배포 후 Railway에서 제공하는 도메인을 사용하여 각 OAuth 제공자의 콜백 URL을 업데이트:

### Google OAuth Console
- Authorized redirect URIs에 추가: `https://your-app.railway.app/users/auth/google_oauth2/callback`

### Kakao Developers Console  
- Redirect URI에 추가: `https://your-app.railway.app/users/auth/kakao/callback`

### Naver Developers Console
- Callback URL에 추가: `https://your-app.railway.app/users/auth/naver/callback`

## 5. 배포 설정
- Build Command: 자동 감지됨 (Dockerfile.railway 사용)
- Start Command: `/app/start.sh`
- Port: 3000 (자동 설정됨)

## 6. 배포 후 확인사항
1. Railway 로그에서 애플리케이션 시작 확인
2. 데이터베이스 마이그레이션 성공 확인
3. OAuth 로그인 테스트
4. YouTube API 연동 테스트

## 문제 해결
- 로그는 Railway 대시보드 > Deployments > View Logs에서 확인
- 환경 변수 누락 시 Variables 탭에서 재설정
- OAuth 에러 시 콜백 URL 재확인