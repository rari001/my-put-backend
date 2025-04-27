Rails.application.routes.draw do
  # 他の認証機能を 'auth' プレフィックスで設定（メール・パスワード認証）
  mount_devise_token_auth_for 'User', at: 'auth'

  # # 他のルート設定
  # get "up" => "rails/health#show", as: :rails_health_check
  # # root "posts#index" などの他のルート設定
  resources :posts, only: [:create, :index, :update, :destroy] do
    resources :comments, only: [:index, :create, :update, :destroy]
    resource :like, only: [:index, :create, :destroy]
    resource :stock, only: [:create, :destroy]
    get '/like_status', to: 'likes#like_status'
    get '/stock_status', to: 'stocks#stock_status'
  end
  resources :top_posts, only: [:index]
  resources :top_users, only: [:index]
  resources :stocks, only: [:index]
  resource :profile, only: [:show, :update]
  get 'users/:id', to: 'profile_users#show', as: :user_profile
  get '/search', to: 'search#index'
  # 通知に関連するルーティング
  resources :notifications, only: [:index] do
    collection do
      get :unread_count  # 未読通知の数を取得
      patch :mark_as_read # 既読にする
    end
  end
  resources :uploads, only: [:create]

  resources :users, only: [:show] do
    resource :relationship, only: [:create, :destroy]
    get :followings, to: 'relationships#followings'
    get :followers, to: 'relationships#followers'
    get :follow_status, to: 'relationships#follow_status'
  end

  root to: 'home#index'
end