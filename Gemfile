source "https://rubygems.org"

ruby "3.1.4"

gem "rails", "7.0.8"
gem "pg", "1.5.4"
gem "puma", "5.6.7"
gem "bootsnap", "1.16.0", require: false

# Authentication
gem "devise", "4.9.3"
gem "omniauth", "1.9.2"
gem "omniauth-google-oauth2", "0.2.6"
gem "omniauth-rails_csrf_protection", "0.1.2"

# Korean SNS OAuth
gem "omniauth-kakao", "0.2.0"
gem "omniauth-naver", "0.2.0"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console", ">= 4.1.0"
  gem "listen", "~> 3.3"
  gem "spring"
end