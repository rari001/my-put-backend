class SearchController < ApplicationController
  def index
    keyword = params[:q]

    # ユーザー名にマッチするユーザーのIDを取得
    user_ids = User.where("username ILIKE ? OR name ILIKE ?", "%#{keyword}%", "%#{keyword}%").pluck(:id)

    # 投稿の本文またはユーザーIDが一致する投稿を検索
    @posts = Post.where("content ILIKE ?", "%#{keyword}%")
                 .or(Post.where(user_id: user_ids))
                 .includes(:user)  # N+1回避のため

    render json: @posts.map { |post| post_data(post) }
  end

  private

  def post_data(post)
    {
      id: post.id,
      userId: post.user.id,
      content: post.content,
      userUserName: post.user.username,
      userName: post.user.name.presence || post.user.email.split('@').first,
      userAvatarUrl: post&.user&.profile&.avatar&.attached? ? url_for(post&.user&.profile&.avatar) : nil,
      created_at: post.created_at
    }
  end
end
