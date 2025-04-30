class ProfileUsersController < ApplicationController
  def show
    user = User.find_by(id: params[:id])

    return render json: { error: "User not found" }, status: :not_found unless user

    profile = user.profile || user.build_profile

    render json: {
      id: profile.id,
      userId: user.id,
      userName: user.name,
      userUserName: user.username,
      email: user.email,
      bio: profile.bio,
      avatarUrl: profile.avatar.attached? ? url_for(profile.avatar) : nil,
      postCount: user.posts.count,
      post: user.posts.order(created_at: :desc).map do |post| {
        id: post.id,
        content: post.content,
        learn: post.learn,
        createdAt: format_post_time(post.created_at),
        updatedAt: format_post_time(post.updated_at),
        userId: post.user_id,
        userName: post.user&.name,
        userUserName: post.user.username,
        userEmail: post.user.email,
        userAvatarUrl: post&.user&.profile&.avatar&.attached? ? url_for(post&.user&.profile&.avatar) : nil
      }
      end
    }
  end

  # 日付フォーマットを制御する
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