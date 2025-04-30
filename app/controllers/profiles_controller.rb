class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    profile = current_user.profile || current_user.build_profile
    render json: profile_data(profile)
  end

  def update
    profile = current_user.profile || current_user.build_profile
    profile.assign_attributes(profile_params)

    # ユーザー名があれば current_user にセット
    current_user.name = params[:profile][:name] if params[:profile][:name].present?

    # 両方を保存（トランザクションでまとめて保存）
    ActiveRecord::Base.transaction do
      current_user.save!
      profile.save!
    end

    render json: profile_data(profile)
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  private

  def profile_params
    params.require(:profile).permit(:bio, :avatar)
  end

  def profile_data(profile)
    user = profile.user

    all_posts = user.posts.order(created_at: :desc)
    learn_posts = all_posts.select(&:learn)

    liked_posts = user.likes.order(created_at: :desc).map(&:post).compact

    {
      id: profile.id,
      userId: user.id,
      userName: user.name,
      userUserName: user.username,
      email: user.email,
      bio: profile.bio,
      avatarUrl: profile.avatar.attached? ? url_for(profile.avatar) : nil,
      postCount: user.posts.count,
      learnCount: learn_posts.count,
      likedCount: user.likes.count,
      hasLikedPosts: user.likes.exists?,
      hasPosts: user.posts.exists?,
      followingsCount: user.followings.count || 0,
      followersCount: user.followers.count || 0,
      post: all_posts.map { |post| serialize_post(post) },
      learnPost: learn_posts.map { |post| serialize_post(post) },
      likedPost: liked_posts.map { |post| serialize_post(post) },
    }
  end

  def serialize_post(post)
    {
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
