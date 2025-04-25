class StocksController < ApplicationController
  def stock_status
    post = Post.find(params[:post_id])
    # ログインしている場合は「ストックしているか」を確認し、ログインしていない場合は false を設定
    stocked = current_user ? post.stocks.exists?(user_id: current_user.id) : false

    render json: { stocked: stocked, count: post.stocks.count }
  end

  def index
    stocked_posts = current_user.stocks.includes(:post).map { |stock| stock.post }
    render json: stocked_posts.map { |post|
      {
        id: post.id,
        content: post.content,
        createdAt: post.created_at.strftime("%Y/%-m/%-d"),
        updatedAt: post.updated_at.strftime("%Y/%-m/%-d"),
        userId: post.user_id,
        userName: post.user&.name,
        userEmail: post.user&.email,
        userAvatarUrl: post&.user&.profile&.avatar&.attached? ? url_for(post&.user&.profile&.avatar) : nil
      }
    }, status: :ok
  end

  def create
    post = Post.find(params[:post_id])
    post.stocks.create(user_id: current_user.id)

    render json: { status: 'ok', stocked: true, count: post.stocks.count }
  end

  def destroy
    post = Post.find(params[:post_id])
    stock = post.stocks.find_by(user_id: current_user.id)

    return render json: { error: "Not found", stocked: false, count: post.stocks.count }, status: :not_found unless stock

    stock.destroy!

    render json: { status: 'ok', stocked: false, count: post.stocks.count }
  end
end