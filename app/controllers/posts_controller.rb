class PostsController < ApplicationController
  def index
    posts = Post.includes(:user).order(created_at: :desc)
    posts = posts.where(learn: true) if params[:learn] == "true"
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
    params.require(:post).permit(:content, :learn)
  end

  def post_data(post)
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