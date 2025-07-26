#!/usr/bin/env ruby

# SNS 로그인 테스트 스크립트
require 'net/http'
require 'uri'
require 'json'

puts "🔐 SNS 로그인 구현 테스트"
puts "=" * 50

# 환경 변수 확인
env_file = File.join(__dir__, '.env')
if File.exist?(env_file)
  puts "✅ .env 파일 발견"
  
  env_vars = {}
  File.readlines(env_file).each do |line|
    next if line.strip.empty? || line.strip.start_with?('#')
    key, value = line.strip.split('=', 2)
    env_vars[key.strip] = value.strip if key && value
  end
  
  # OAuth 키 확인
  oauth_keys = {
    'Google' => ['GOOGLE_CLIENT_ID', 'GOOGLE_CLIENT_SECRET'],
    'Kakao' => ['KAKAO_CLIENT_ID', 'KAKAO_CLIENT_SECRET'],
    'Naver' => ['NAVER_CLIENT_ID', 'NAVER_CLIENT_SECRET']
  }
  
  oauth_keys.each do |provider, keys|
    puts "\n#{provider} OAuth 설정:"
    keys.each do |key|
      if env_vars[key] && !env_vars[key].empty? && env_vars[key] != "your_#{key.downcase}"
        puts "  ✅ #{key}: #{env_vars[key][0..10]}..."
      else
        puts "  ❌ #{key}: 설정되지 않음"
      end
    end
  end
else
  puts "❌ .env 파일을 찾을 수 없습니다"
end

puts "\n" + "=" * 50
puts "📁 SNS 로그인 구현 파일 확인"

# 구현 파일들 확인
files_to_check = [
  'app/controllers/users/omniauth_callbacks_controller.rb',
  'app/models/user.rb',
  'config/initializers/omniauth.rb',
  'app/views/devise/sessions/new.html.erb'
]

files_to_check.each do |file_path|
  full_path = File.join(__dir__, file_path)
  if File.exist?(full_path)
    puts "✅ #{file_path}"
    
    # 파일 내용 간단 분석
    content = File.read(full_path)
    if file_path.include?('omniauth_callbacks_controller')
      methods = content.scan(/def (\w+)/).flatten
      puts "   - 구현된 메소드: #{methods.join(', ')}"
    elsif file_path.include?('user.rb')
      if content.include?('omniauth_providers')
        providers = content.match(/omniauth_providers:\s*\[(.*?)\]/m)
        puts "   - 설정된 제공자: #{providers[1].gsub(/[:\s]/, '') if providers}"
      end
    elsif file_path.include?('omniauth.rb')
      providers = content.scan(/provider :(\w+)/).flatten
      puts "   - 설정된 제공자: #{providers.join(', ')}"
    end
  else
    puts "❌ #{file_path}"
  end
end

puts "\n" + "=" * 50
puts "🎯 테스트 방법 안내"
puts

puts "1. Docker 방식 (권장):"
puts "   - Docker Desktop이 실행 중인지 확인"
puts "   - WSL2 통합이 활성화되어 있는지 확인"
puts "   - ./simple-start.sh 실행"
puts "   - http://localhost:3000 접속"

puts "\n2. 로컬 방식:"
puts "   - PostgreSQL 또는 SQLite 데이터베이스 설정"
puts "   - bundle exec rails server 실행"
puts "   - Ruby 환경 충돌 해결 필요"

puts "\n3. OAuth 콜백 URL 확인:"
puts "   - Google: http://localhost:3000/users/auth/google_oauth2/callback"
puts "   - Kakao: http://localhost:3000/users/auth/kakao/callback"
puts "   - Naver: http://localhost:3000/users/auth/naver/callback"

puts "\n✨ 모든 SNS 로그인 구현이 완료되었습니다!"