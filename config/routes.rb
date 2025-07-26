require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root 'home#index'

  # Sidekiq Web UI (protect in production)
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?

  # Main analysis routes
  resources :channels, only: [:show] do
    member do
      get :search
    end
  end

  resources :analysis_reports, only: [:show, :create] do
    member do
      get :pdf
      get :csv
      patch :extend_permalink
    end
  end

  # Public permalink routes
  get '/reports/:permalink_token', to: 'analysis_reports#public_show', as: :public_report

  # User dashboard
  resources :dashboard, only: [:index] do
    collection do
      get :history
      get :favorites
    end
  end

  # API routes
  namespace :api do
    namespace :v1 do
      resources :channels, only: [:show] do
        collection do
          post :analyze
          get :search
        end
      end
      
      resources :analysis_reports, only: [:show, :index]
    end
  end

  # Health check
  get '/health', to: 'application#health'
end