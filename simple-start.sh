#!/bin/bash

echo "🐳 Simple Docker 실행 스크립트"

# PostgreSQL 실행
echo "📊 PostgreSQL 시작..."
docker run -d --name youlytic-postgres \
  -e POSTGRES_DB=youlytic_development \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  postgres:15-alpine

# Redis 실행  
echo "🔴 Redis 시작..."
docker run -d --name youlytic-redis \
  -p 6379:6379 \
  redis:7-alpine

# 잠시 대기
sleep 5

# Rails 앱 빌드 및 실행
echo "🚀 Rails 앱 빌드 중..."
docker build -t youlytic-app .

echo "🌐 Rails 서버 시작..."
docker run -d --name youlytic-web \
  -p 3000:3000 \
  -e DATABASE_HOST=host.docker.internal \
  -e DATABASE_USERNAME=postgres \
  -e DATABASE_PASSWORD=password \
  -e REDIS_URL=redis://host.docker.internal:6379/0 \
  -e YOUTUBE_API_KEY=AIzaSyBRtIjCIBjklW6mBxYpeT8VBhoebWuvA9c \
  -e RAILS_ENV=development \
  youlytic-app

echo "✅ 서버 시작 완료!"
echo "🌍 브라우저에서 http://localhost:3000 접속하세요"

# 상태 확인
docker ps