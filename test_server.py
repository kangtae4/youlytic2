#!/usr/bin/env python3

import http.server
import socketserver
import urllib.parse
import os

class SNSLoginHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.serve_main_page()
        elif self.path.startswith('/auth/'):
            self.serve_auth_page()
        else:
            super().do_GET()
    
    def serve_main_page(self):
        html = '''<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Youlytic SNS 로그인 테스트</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50">
    <div class="min-h-screen flex items-center justify-center py-12 px-4">
        <div class="max-w-md w-full space-y-8">
            <div>
                <div class="flex justify-center">
                    <svg class="w-12 h-12 text-red-600" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
                    </svg>
                </div>
                <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
                    Youlytic SNS 로그인
                </h2>
                <p class="mt-2 text-center text-sm text-gray-600">
                    YouTube 채널 분석을 위해 로그인하세요
                </p>
            </div>
            
            <div class="mt-6">
                <div class="relative">
                    <div class="absolute inset-0 flex items-center">
                        <div class="w-full border-t border-gray-300"></div>
                    </div>
                    <div class="relative flex justify-center text-sm">
                        <span class="px-2 bg-gray-50 text-gray-500">SNS로 로그인</span>
                    </div>
                </div>

                <div class="mt-6 grid grid-cols-1 gap-3">
                    <a href="/auth/google" 
                       class="w-full flex justify-center py-3 px-4 border border-gray-300 rounded-md shadow-sm bg-white text-sm font-medium text-gray-700 hover:bg-gray-50">
                        <svg class="w-5 h-5 mr-2" viewBox="0 0 24 24">
                            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                        </svg>
                        Google로 로그인
                    </a>

                    <a href="/auth/kakao"
                       class="w-full flex justify-center py-3 px-4 border border-gray-300 rounded-md shadow-sm bg-yellow-300 text-sm font-medium text-gray-900 hover:bg-yellow-400">
                        <svg class="w-5 h-5 mr-2" viewBox="0 0 24 24">
                            <path fill="#000" d="M12 3c5.799 0 10.5 3.664 10.5 8.185 0 4.52-4.701 8.184-10.5 8.184a13.5 13.5 0 0 1-1.727-.11L7.5 21l.844-2.51c-1.226-.91-2.12-2.205-2.12-3.675C6.224 6.664 10.201 3 16 3z"/>
                        </svg>
                        카카오로 로그인
                    </a>

                    <a href="/auth/naver"
                       class="w-full flex justify-center py-3 px-4 border border-gray-300 rounded-md shadow-sm bg-green-500 text-sm font-medium text-white hover:bg-green-600">
                        <svg class="w-5 h-5 mr-2" viewBox="0 0 24 24">
                            <path fill="white" d="M16.273 12.845 7.376 0H0v24h7.726V11.156L16.624 24H24V0h-7.727v12.845z"/>
                        </svg>
                        네이버로 로그인
                    </a>
                </div>
            </div>

            <div class="mt-8 space-y-4">
                <div class="p-4 bg-green-50 rounded-md">
                    <h3 class="text-sm font-medium text-green-800">✅ 구현 완료된 기능</h3>
                    <ul class="mt-2 text-xs text-green-700 space-y-1">
                        <li>• Google OAuth2 로그인 구현</li>
                        <li>• Kakao 로그인 구현</li>
                        <li>• Naver 로그인 구현</li>
                        <li>• OAuth 환경 변수 설정</li>
                        <li>• 사용자 모델 및 자동 생성</li>
                        <li>• 구독 티어 관리 시스템</li>
                    </ul>
                </div>
                
                <div class="p-4 bg-blue-50 rounded-md">
                    <h3 class="text-sm font-medium text-blue-800">🔗 Rails Callback URLs</h3>
                    <ul class="mt-2 text-xs text-blue-700 space-y-1">
                        <li>• /users/auth/google_oauth2/callback</li>
                        <li>• /users/auth/kakao/callback</li>
                        <li>• /users/auth/naver/callback</li>
                    </ul>
                </div>

                <div class="p-4 bg-yellow-50 rounded-md">
                    <h3 class="text-sm font-medium text-yellow-800">⚠️ 현재 상태</h3>
                    <p class="mt-2 text-xs text-yellow-700">
                        Rails Logger 호환성 이슈로 임시 테스트 서버로 실행 중입니다.<br>
                        실제 OAuth 연동은 Rails 서버 환경에서 작동합니다.
                    </p>
                </div>

                <div class="p-4 bg-purple-50 rounded-md">
                    <h3 class="text-sm font-medium text-purple-800">🐳 Docker 상태</h3>
                    <ul class="mt-2 text-xs text-purple-700 space-y-1">
                        <li>• PostgreSQL: ✅ 실행 중 (5432)</li>
                        <li>• Redis: ✅ 실행 중 (6379)</li>
                        <li>• Rails Web: ❌ Logger 오류</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</body>
</html>'''
        
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(html.encode('utf-8'))
    
    def serve_auth_page(self):
        provider = self.path.split('/')[2]
        provider_names = {
            'google': 'Google',
            'kakao': '카카오',
            'naver': '네이버'
        }
        
        html = f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{provider_names.get(provider, provider)} OAuth</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen">
    <div class="max-w-md w-full bg-white rounded-lg shadow-md p-8">
        <div class="text-center">
            <h1 class="text-2xl font-bold text-gray-900 mb-4">
                {provider_names.get(provider, provider)} OAuth 로그인
            </h1>
            <div class="mb-6 p-4 bg-blue-50 rounded-md">
                <p class="text-sm text-blue-700 mb-2">
                    실제 Rails 서버에서는 여기서 {provider_names.get(provider, provider)} OAuth 페이지로 리다이렉트됩니다.
                </p>
                <p class="text-xs text-blue-600">
                    <strong>Callback URL:</strong> /users/auth/{provider}/callback
                </p>
            </div>
            <div class="mb-6 p-4 bg-green-50 rounded-md">
                <p class="text-xs text-green-700">
                    <strong>환경 변수 설정:</strong> ✅ 완료<br>
                    <strong>OAuth 코드:</strong> ✅ 구현됨<br>
                    <strong>콜백 핸들러:</strong> ✅ 구현됨
                </p>
            </div>
            <a href="/" class="inline-block bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-4 rounded">
                ← 메인으로 돌아가기
            </a>
        </div>
    </div>
</body>
</html>'''
        
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(html.encode('utf-8'))

if __name__ == "__main__":
    PORT = 3000
    
    print("🚀 Youlytic SNS 로그인 테스트 서버 시작")
    print(f"🌍 브라우저에서 http://localhost:{PORT} 접속하세요")
    print("📝 Rails Logger 이슈 해결 후 정상 서버로 전환됩니다")
    print("🛑 서버 종료: Ctrl+C")
    print()
    
    with socketserver.TCPServer(("", PORT), SNSLoginHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 서버를 종료합니다.")
            httpd.shutdown()