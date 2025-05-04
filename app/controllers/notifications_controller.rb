class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def unread_count
    unread_count = current_user.notifications.where(read: false).count
    render json: { unread: unread_count }
  end

  # 通知一覧を表示
  def index
    @notifications = current_user.notifications.includes(:comment, :user, :like).order(created_at: :desc)

    render json: @notifications.map { |notification|
      {
        id: notification.id,
        message: notification.message,
        read: notification.read,
        createdAt: format_time(notification.created_at),
        commentContent: notification.comment&.content, # コメント内容
        postId: notification.post&.id, # 通知が関連する投稿のID
        commentId: notification.comment&.id, # コメントID
        mentionedUserId: notification.user.id, # メンションされたユーザーID
        mentionedUserName: notification.user.name, # メンションされたユーザー名
        senderId: notification.comment&.user&.id, # メンションを送ったユーザーID
        senderName: notification.comment&.user&.name.presence || notification.comment&.user&.email&.split('@')&.first, # メンションを送ったユーザー名
        senderEmail: notification.comment&.user&.email, # メンションを送ったユーザーのメール
        senderUserName: notification.comment&.user&.username,# メンションを送ったユーザーのメユーザー名
        senderUserAvatarUrl: notification.comment&.user&.profile&.avatar&.attached? ? url_for(notification.comment&.user&.profile&.avatar) : nil,
        # いいねに関する
        likeId: notification.like&.id, # likeが関連していればそのID
        likeUserId: notification.like&.user&.id, # likeしたユーザーのID
        likeCreatedAt: notification.like&.created_at, # likeが作成された日時
        likeSenderName: notification.like&.user&.name.presence || notification.like&.user&.email&.split('@')&.first,
        likeSenderUserName: notification.like&.user&.username,
        likeSenderAvatarUrl: notification.like&.user&.profile&.avatar&.attached? ? url_for(notification.like&.user&.profile&.avatar) : nil,
        # フォローに関する
        relationId: notification.relationship&.id,
        followSenderId: notification.relationship&.follower&.id,
        followSenderName: notification.relationship&.follower&.name.presence || notification.relationship&.follower&.email&.split('@')&.first,
        followSenderUserName: notification.relationship&.follower&.username,
        followSenderAvatarUrl: notification.relationship&.follower&.profile&.avatar&.attached? ? url_for(notification.relationship&.follower&.profile&.avatar) : nil,
      }
    }, status: :ok
  end

  # 通知を既読にする
  def mark_as_read
    notifications = current_user.notifications.where(id: params[:ids])

    if notifications.empty?
      render json: { error: 'Notifications not found.' }, status: :not_found
      return
    end

    notifications.each do |notification|
      notification.update(read: true)
    end

    render json: { message: 'Notifications marked as read.' }, status: :ok
  end

  private

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
