class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  # Reactのクライアントサイドのルーティングに対応するために追加
  def frontend
    # publicフォルダのindex.htmlを返す
    render file: 'public/index.html', layout: false, status: :ok
  end
end
