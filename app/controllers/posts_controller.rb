class PostsController < ApplicationController
  def create
    post = Post.new(post_params)

    if post.save
      render json: { post: post }, status: :created
    else
      render json: { error: "投稿の作成に失敗しました" }, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:content)
  end
end
