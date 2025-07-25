source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "rails", "~> 7.0.0"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "sass-rails", ">= 6"
gem "webpacker", "~> 5.0"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder", "~> 2.7"
gem "bootsnap", ">= 1.4.4", require: false
gem "image_processing", "~> 1.2"

# YouTube API and HTTP
gem "google-api-client"
gem "httparty"

# Background jobs
gem "sidekiq"
gem "sidekiq-web"
gem "redis", "~> 4.0"

# Charts and visualization
gem "chartkick"
gem "groupdate"

# Authentication
gem "devise"

# Pagination
gem "kaminari"

# Environment variables
gem "dotenv-rails"

# PDF generation
gem "wicked_pdf"
gem "wkhtmltopdf-binary"

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