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
      createdAt: format_post_time(post.created_at),
    }
  end

  def format_post_time(time)
    return "" unless time.is_a?(Time) || time.is_a?(DateTime)
    local_time = time.in_time_zone # ← タイムゾーン補正
    if local_time.to_date == Time.current.to_date
      format_time(local_time)
    else
      local_time.strftime("%Y/%-m/%-d")
    end
  end

 # 時間のフォーマット
  def format_time(time)
    time_in_zone = time.in_time_zone
    time_diff = Time.current - time_in_zone
    if time_diff < 60
      "#{time_diff.to_i}秒前"
    elsif time_diff < 3600
      "#{(time_diff / 60).to_i}分前"
    elsif time_diff < 86400
      "#{(time_diff / 3600).to_i}時間前"
    else
      "#{(time_diff / 86400).to_i}日前"
    end
  end
end