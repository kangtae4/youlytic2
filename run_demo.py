#!/usr/bin/env python3
import http.server
import socketserver
import webbrowser
import os
import sys

PORT = 8080

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.getcwd(), **kwargs)

def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"✅ Youlytic 데모가 실행되었습니다!")
        print(f"📱 브라우저에서 http://localhost:{PORT}/demo.html 을 열어주세요")
        print(f"🚀 또는 직접 demo.html 파일을 브라우저에서 열어주세요")
        print(f"🛑 서버를 중지하려면 Ctrl+C를 누르세요")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n서버가 종료되었습니다.")
            sys.exit(0)

if __name__ == "__main__":
    main()