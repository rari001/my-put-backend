class TopPostsController < ApplicationController
  def index
    top_posts = Post.joins(:likes)
                    .group('posts.id')
                    .order('COUNT(likes.id) DESC')
                    .limit(3)
                    .to_a

    if top_posts.size < 3
      additional_posts = Post.where.not(id: top_posts.map(&:id))
                             .order(created_at: :desc)
                             .limit(3 - top_posts.size)
      top_posts += additional_posts
    end

    render json: top_posts.map { |post| post_data(post) }, status: :ok
  end

  private

  def post_data(post)
    {
      id: post.id,
      content: post.content,
      likeCount: post.likes.count,
      createdAt: format_time(post.created_at)
    }
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
