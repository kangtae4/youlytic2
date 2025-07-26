#!/bin/bash

echo "🚀 Fly.io 배포 시작..."

# 1. Fly.io 로그인 확인
echo "📋 Fly.io 로그인 상태 확인..."
flyctl auth whoami || {
    echo "❌ Fly.io에 로그인이 필요합니다."
    echo "다음 명령어를 실행하세요: flyctl auth login"
    exit 1
}

# 2. 앱 생성 (이미 존재하면 스킵)
echo "📱 Fly.io 앱 생성..."
flyctl apps create youlytic2-sns --org personal 2>/dev/null || echo "앱이 이미 존재합니다."

# 3. PostgreSQL 데이터베이스 생성
echo "🗄️ PostgreSQL 데이터베이스 생성..."
flyctl postgres create --name youlytic2-sns-db --region nrt --vm-size shared-cpu-1x --volume-size 1 || echo "데이터베이스가 이미 존재할 수 있습니다."

# 4. 데이터베이스 연결
echo "🔗 데이터베이스 연결..."
flyctl postgres attach youlytic2-sns-db --app youlytic2-sns || echo "데이터베이스 연결 시도..."

# 5. 환경 변수 설정
echo "🔧 환경 변수 설정..."
flyctl secrets set \
    RAILS_ENV=production \
    SECRET_KEY_BASE=$(openssl rand -hex 64) \
    GOOGLE_CLIENT_ID=test_google_client_id \
    GOOGLE_CLIENT_SECRET=test_google_client_secret \
    KAKAO_CLIENT_ID=test_kakao_client_id \
    KAKAO_CLIENT_SECRET=test_kakao_client_secret \
    NAVER_CLIENT_ID=test_naver_client_id \
    NAVER_CLIENT_SECRET=test_naver_client_secret \
    --app youlytic2-sns

# 6. 배포
echo "🚀 앱 배포 중..."
flyctl deploy --dockerfile Dockerfile.fly --app youlytic2-sns

# 7. 앱 열기
echo "🌐 앱 열기..."
flyctl open --app youlytic2-sns

echo "✅ 배포 완료!"
echo "📱 앱 URL: https://youlytic2-sns.fly.dev"