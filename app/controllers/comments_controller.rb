class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: [:update, :destroy]

  # コメント一覧を取得する
  def index
    @comments = Comment.includes(:user).where(post_id: params[:post_id])

    render json: @comments.map { |comment| comment_json(comment) }, status: :ok
  end

  # コメントを作成する
  def create
    comment = @post.comments.new(comment_params)
    comment.user = current_user

    if comment.save
      # メンションと通知の処理
      mention_flag = handle_mentions(comment)

      render json: comment_json(comment, mention_flag), status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # コメントを更新する
  def update
    if @comment.update(comment_params)
      # メンションと通知の処理
      mention_flag = handle_mentions(@comment)

      render json: comment_json(@comment, mention_flag), status: :ok
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # コメントを削除する
  def destroy
    @comment.destroy
    head :no_content
  end

  private

  def comment_json(comment, mention_flag = nil)
    {
      id: comment.id,
      content: comment.content,
      postId: comment.post_id,
      userId: comment.user_id,
      userName: comment.user&.name,
      userEmail: comment.user&.email,
      createdAt: format_time(comment.created_at),
      updatedAt: format_time(comment.updated_at),
      mention: mention_flag.nil? ? comment.mentions.exists? : mention_flag,
      mentionUsers: comment.mentions.includes(:user).map { |mention| { id: mention.user.id, username: mention.user.username } },
      userAvatarUrl: comment&.user&.profile&.avatar&.attached? ? url_for(comment&.user&.profile&.avatar) : nil
    }
  end

  # メンションを検出して処理する
  def handle_mentions(comment)
    mentioned_usernames = comment.content.scan(/@([a-zA-Z0-9._-]+)/).flatten
    mention_flag = false

    mentioned_usernames.each do |username|
      puts "検索対象のusername: #{username}"
      # usernameに@を付けて検索
      user = User.find_by(username: "@#{username}")

      if user
        # メンションを保存
        Mention.create(comment: comment, post: comment.post, user: user)

        # メンションを送ったユーザーの名前を使って通知を作成
        notification_message = "#{comment.user.name.presence || comment.user.email.split('@').first}さんがあなたをメンションしました。"

        Notification.create(
          user: user,  # メンションされたユーザー
          post: comment.post,
          comment: comment,
          message: notification_message, # メンションを送ったユーザー名
        )

        mention_flag = true
      end
    end
  end

  # ユーザー名を取得するヘルパー
  def get_user_name_or_email(user)
    if user.name.present?
      user.name
    else
      user.email.split('@').first # メールアドレスの@前部分を表示
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

  # 現在のポストをセット
  def set_post
    @post = Post.find(params[:post_id])
  end

  # 現在のコメントをセット
  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  # コメントパラメータのストロングパラメータ
  def comment_params
    params.require(:comment).permit(:content)
  end
end
