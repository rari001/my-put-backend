class GuestSessionsController < ApplicationController
  def create
    guest_email = "guest_#{SecureRandom.alphanumeric(5)}@example.com"
    guest_password = SecureRandom.alphanumeric(8)

    user = User.new(
      email: guest_email,
      password: guest_password,
      password_confirmation: guest_password,
      guest: true
    )

    if user.save
      # ログイン処理（トークン生成）
      sign_in(:user, user, store: false)
      # トークンを取得
      token = user.create_new_auth_token
      # トークンをレスポンスヘッダーに追加
      response.headers.merge!(token)

      render json: { message: "ゲストログインしました", user: user }
    else
      render json: { error: "ゲストユーザー作成に失敗しました", details: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
