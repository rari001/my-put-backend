class SearchController < ApplicationController
  def index
    keyword = params[:q]

    # ユーザー検索（名前またはユーザー名）
    @matched_users = User.where("username ILIKE ? OR name ILIKE ?", "%#{keyword}%", "%#{keyword}%")
                         .includes(:profile)

    user_ids = @matched_users.pluck(:id)

    # 投稿検索：本文または一致ユーザーの投稿
    @posts = Post.where("content ILIKE ?", "%#{keyword}%")
                 .or(Post.where(user_id: user_ids))
                 .includes(:user)

    # 投稿に関連するユーザーID一覧（投稿が存在するユーザー）
    post_user_ids = @posts.map(&:user_id).uniq

    # 投稿が見つからなかったユーザーのみ抽出
    @users_without_posts = @matched_users.reject { |user| post_user_ids.include?(user.id) }

    render json: {
      posts: @posts.map { |post| post_data(post) },
      users: @users_without_posts.map { |user| user_data(user) }
    }
  end

  private

  def user_data(user)
    {
      id: user.id,
      userName: user.name.presence || user.email.split('@').first,
      userUserName: user.username,
      bio: user.profile&.bio,
      avatarUrl: user.profile&.avatar&.attached? ? url_for(user.profile.avatar) : nil
    }
  end

  def post_data(post)
    {
      id: post.id,
      userId: post.user.id,
      content: post.content,
      userUserName: post.user.username,
      userName: post.user.name.presence || post.user.email.split('@').first,
      userAvatarUrl: post.user&.profile&.avatar&.attached? ? url_for(post.user.profile.avatar) : nil,
      createdAt: format_post_time(post.created_at),
    }
  end

  def format_post_time(time)
    return "" unless time.is_a?(Time) || time.is_a?(DateTime)
    local_time = time.in_time_zone
    if local_time.to_date == Time.current.to_date
      format_time(local_time)
    else
      local_time.strftime("%Y/%-m/%-d")
    end
  end

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
