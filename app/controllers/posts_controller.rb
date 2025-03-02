class PostsController < ApplicationController
  def index
    @posts = Post.all

    render json: @posts, status: :ok
  end

  def create
    # current_user.id を使って、ユーザーIDを設定
    @post = Post.new(post_params)
    @post.user_id = current_user.id  # ユーザーIDを明示的に設定

    if @post.save
      render json: @post, status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end
end
