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
    {
      id: profile.id,
      userId: profile.user.id,
      userName: profile.user.name,
      userUserName: profile.user.username,
      email: profile.user.email,
      bio: profile.bio,
      avatarUrl: profile.avatar.attached? ? url_for(profile.avatar) : nil,
      postCount: profile.user.posts.count,
      likedCount: profile.user.likes.count,
      hasLikedPosts: profile.user.likes.exists?,
      hasPosts: profile.user.posts.exists?,
      followingsCount: profile.user.followings.count || 0,
      followersCount: profile.user.followers.count || 0,
      post: profile.user.posts.order(created_at: :desc).map do |post|  # ここを変更
        {
          id: post.id,
          content: post.content,
          createdAt: post.created_at.strftime("%Y/%-m/%-d"),
          updatedAt: post.updated_at.strftime("%Y/%-m/%-d"),
          userId: post.user_id,
          userName: post.user&.name,
          userUserName: post.user.username,
          userEmail: post.user.email,
          userAvatarUrl: post&.user&.profile&.avatar&.attached? ? url_for(post&.user&.profile&.avatar) : nil
        }
      end,
      likedPost: profile.user&.likes.order(created_at: :desc).map(&:post).compact.map do |post|
        {
          id: post.id,
          content: post.content,
          createdAt: post.created_at.strftime("%Y/%-m/%-d"),
          updatedAt: post.updated_at.strftime("%Y/%-m/%-d"),
          userId: post.user_id,
          userName: post.user&.name,
          userUserName: post.user.username,
          userEmail: post.user.email,
          userAvatarUrl: post&.user&.profile&.avatar&.attached? ? url_for(post&.user&.profile&.avatar) : nil
        }
      end
    }
  end
end
