class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::Cookies
  before_action :split_token

  private
  # ゲストログイン時のトークンの設定
  def split_token
    return if cookies["_access_token"].nil? || cookies["_client"].nil? || cookies["_uid"].nil?

    request.headers['access-token'] = cookies["_access_token"]
    request.headers['client'] = cookies["_client"]
    request.headers['uid'] = cookies["_uid"]
  end

end
