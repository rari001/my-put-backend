class TopUsersController < ApplicationController
  def index
    # フォロワー数が多い順にUserを取得
    top_followers = User.left_joins(:follower_relationships)
                    .select('users.*, COUNT(relationships.id) AS followers_count')
                    .group('users.id')
                    .order('followers_count DESC')
                    .limit(3)

    # 3人未満なら、いいね数が多いユーザーを代わりに取得
    if top_followers.length < 3
      top_users_by_likes = User.joins(posts: :likes)
                               .select('users.*, COUNT(likes.id) AS total_likes')
                               .group('users.id')
                               .order('total_likes DESC')
                               .limit(3)
      @top_users = top_users_by_likes
    else
      @top_users = top_followers
    end

    render json: @top_users.map { |user| user_data(user) }
  end

  private

  def user_data(user)
    {
      id: user.id,
      name: user.name.presence || user.email.split('@').first,
      username: user.username,
      email: user.email,
      avatarUrl: user.profile&.avatar&.attached? ? url_for(user.profile.avatar) : nil
    }
  end
end
