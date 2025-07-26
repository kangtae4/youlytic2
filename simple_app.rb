require 'sinatra'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'omniauth-kakao'
require 'omniauth-naver'

class SimpleOAuthApp < Sinatra::Base
  configure do
    use Rack::Session::Cookie, secret: ENV['SECRET_KEY_BASE'] || 'super_secret_key'
    
    use OmniAuth::Builder do
      provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
      provider :kakao, ENV['KAKAO_CLIENT_ID'], ENV['KAKAO_CLIENT_SECRET']  
      provider :naver, ENV['NAVER_CLIENT_ID'], ENV['NAVER_CLIENT_SECRET']
    end
  end

  get '/' do
    <<-HTML
    <h1>SNS 로그인 테스트</h1>
    <a href="/auth/google_oauth2">Google 로그인</a><br>
    <a href="/auth/kakao">Kakao 로그인</a><br>
    <a href="/auth/naver">Naver 로그인</a><br>
    HTML
  end

  get '/auth/:provider/callback' do
    auth = request.env['omniauth.auth']
    "<h1>로그인 성공!</h1><p>Provider: #{auth.provider}</p><p>Name: #{auth.info.name}</p><p>Email: #{auth.info.email}</p>"
  end

  get '/auth/failure' do
    "<h1>로그인 실패</h1><p>#{params[:message]}</p>"
  end
end

if __FILE__ == $0
  SimpleOAuthApp.run! host: '0.0.0.0', port: ENV['PORT'] || 4567
end