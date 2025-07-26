Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
  provider :kakao, ENV['KAKAO_CLIENT_ID'], ENV['KAKAO_CLIENT_SECRET']
  provider :naver, ENV['NAVER_CLIENT_ID'], ENV['NAVER_CLIENT_SECRET']
end

OmniAuth.config.allowed_request_methods = [:post, :get]