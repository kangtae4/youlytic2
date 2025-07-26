source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.4"

gem "rails", "~> 6.1.7"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "sass-rails", ">= 6"
gem "webpacker", "~> 5.0"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder", "~> 2.7"
gem "bootsnap", ">= 1.4.4", require: false

# YouTube API and HTTP
gem "google-api-client"
gem "httparty"

# Background jobs
gem "sidekiq"
gem "redis", "~> 4.0"

# Charts and visualization
gem "chartkick"
gem "groupdate"

# Authentication
gem "devise"
gem "omniauth"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"

# Korean SNS OAuth
gem "omniauth-kakao"
gem "omniauth-naver"

# Pagination
gem "kaminari"

# Environment variables
gem "dotenv-rails", groups: [:development, :test]

# PDF generation (simplified for production)
gem "wicked_pdf"

# JSON handling
gem "oj"

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