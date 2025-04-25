class RelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:create, :destroy, :followings, :followers, :follow_status]

  def follow_status
    # 現在のユーザーが指定したユーザーをフォローしているかどうかを確認
    following = current_user.followings.exists?(@user.id)

    render json: {
      isFollowed: following,
      followingsCount: @user.followings.count,
      followersCount: @user.followers.count
    }
  end

  # フォロー
  def create
    # 既にフォロー関係が存在するかを確認
    if current_user.following_relationships.exists?(following_id: @user.id)
      render json: { message: "Already following" }, status: :unprocessable_entity
    else
      # フォロー関係を作成
      follow_create = current_user.following_relationships.create(following_id: @user.id)

      if follow_create.persisted?  # 作成が成功したかどうかを確認
        render json: {
          message: "User followed",
          isFollowed: true,
          followingsCount: @user.followings.count,
          followersCount: @user.followers.count
        }, status: :created
      else
        render json: { message: "Unable to follow user" }, status: :unprocessable_entity
      end
    end
  end

  # アンフォロー
  def destroy
    relationship = current_user.following_relationships.find_by(following_id: @user.id)
    if relationship
      relationship.destroy
      render json: {
        message: "User unfollowed",
        isFollowed: false,
        followingsCount: @user.followings.count,
        followersCount: @user.followers.count
      }, status: :ok
    else
      render json: { message: "Not following user" }, status: :unprocessable_entity
    end
  end

  # フォロー一覧
def followings
  followings = @user.followings.order(:created_at)

  render json: followings.map { |user| user_data(user) }, status: :ok
end

# フォロワー一覧
def followers
  followers = @user.followers.order(:created_at)

  render json: followers.map { |user| user_data(user) }, status: :ok
end


  private

  def set_user
    @user = User.find_by(id: params[:user_id])
    unless @user
      render json: { message: "User not found" }, status: :not_found
    end
  end

  def user_data(user)
    {
      id: user.id,
      name: user.name.presence || user.email.split('@').first,
      username: user.username,
      bio: user.profile&.bio,
      followingsCount: user.followings.count || 0,
      followersCount: user.followers.count || 0,
      email: user.email,
      avatarUrl: user&.profile&.avatar&.attached? ? url_for(user&.profile&.avatar) : nil,
    }
  end
end
