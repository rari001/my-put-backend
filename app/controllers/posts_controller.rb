class PostsController < ApplicationController
  def index
    posts = Post.includes(:user).order(created_at: :desc)
    render json: posts.map { |post| post_data(post) }, status: :ok
  end

  def create
    return render json: { error: "Unauthorized" }, status: :unauthorized unless current_user

    post = current_user.posts.build(post_params)

    if post.save
      render json: post_data(post), status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    post = current_user.posts.find_by(id: params[:id])

    if post.update(post_params)
      render json: post_data(post), status: :ok
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    post = current_user.posts.find_by(id: params[:id])

    if post.destroy
      render json: { message: "Post deleted successfully" }, status: :ok
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end

  def post_data(post)
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
end
