Rails.application.routes.draw do
  # 他の認証機能を 'auth' プレフィックスで設定（メール・パスワード認証）
  mount_devise_token_auth_for 'User', at: 'auth'

  # # 他のルート設定
  # get "up" => "rails/health#show", as: :rails_health_check
  # # root "posts#index" などの他のルート設定
  resources :posts, only: [:create, :index]
  resources :uploads, only: [:create]
end
