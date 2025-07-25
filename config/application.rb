require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Youlytic
  class Application < Rails::Application
    config.load_defaults 7.0

    # Time zone
    config.time_zone = 'Asia/Seoul'

    # Sidekiq
    config.active_job.queue_adapter = :sidekiq

    # CORS
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end

    # Custom configurations
    config.x.youtube_api_quota_limit = 10000
    config.x.default_video_fetch_limit = 50
  end
end