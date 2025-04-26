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