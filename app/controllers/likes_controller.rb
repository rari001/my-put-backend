class LikesController < ApplicationController
  # 投稿に対するいいねの状態を確認
  def like_status
    post = Post.find(params[:post_id])

    # ログインしている場合は「いいねしているか」を確認し、ログインしていない場合は false を設定
    liked = current_user ? post.likes.exists?(user_id: current_user.id) : false

    render json: { liked: liked, count: post.likes.count }
  end

  # いいねを作成し、通知を送信する
  def create
    post = Post.find(params[:post_id])

    # いいねを作成
    like = post.likes.create(user_id: current_user.id)

    # 投稿者（投稿を作成したユーザー）を取得
    post_owner = post.user

    # 自分の投稿に対する「いいね」には通知を送らない
    if post_owner != current_user
      # 通知メッセージ
      notification_message = if current_user.email.present?
                               "#{current_user.name.presence || current_user.email.split('@').first} さんがあなたの投稿にいいねしました。"
                             else
                               "#{current_user.name} さんがあなたの投稿にいいねしました。"
                             end

      # 投稿者に通知を送る
      Notification.create(
        user: post_owner,  # 通知を受け取るユーザー（投稿者）
        post: post,
        like_id: like.id,
        message: notification_message
      )
    end

    render json: { status: 'ok', liked: true, count: post.likes.count }
  end

  # いいねを解除する
  def destroy
    post = Post.find(params[:post_id])
    like = post.likes.find_by(user_id: current_user.id)

    return render json: { error: "Not found", liked: false, count: post.likes.count }, status: :not_found unless like

    like.destroy!
    render json: { status: 'ok', liked: false, count: post.likes.count }
  end
end
