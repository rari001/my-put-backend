class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def unread_count
    unread_count = current_user.notifications.where(read: false).count
    render json: { unread: unread_count }
  end

  def index
    @notifications = current_user.notifications
      .includes(
        :comment, :like, :user,
        relationship: { follower: [:profile] },
        comment: { user: [:profile] },
        like: { user: [:profile] }
      )
      .order(created_at: :desc)

    render json: @notifications.map { |notification|
      sender_user =
        if notification.comment.present?
          notification.comment.user
        elsif notification.like.present?
          notification.like.user
        elsif notification.relationship.present?
          notification.relationship.follower
        end

      {
        id: notification.id,
        message: notification.message,
        read: notification.read,
        createdAt: format_time(notification.created_at),

        # メンション通知関連
        commentContent: notification.comment&.content,
        postId: notification.post&.id,
        commentId: notification.comment&.id,
        mentionedUserId: notification.user.id,
        mentionedUserName: notification.user.name,

        # 通知の送信者（共通）
        senderId: sender_user&.id,
        senderName: sender_user&.name.presence || sender_user&.email&.split('@')&.first,
        senderUserName: sender_user&.username,
        senderEmail: sender_user&.email,
        senderUserAvatarUrl: sender_user&.profile&.avatar&.attached? ? url_for(sender_user.profile.avatar) : nil,

        # いいね通知関連
        likeId: notification.like&.id,

        # フォロー通知関連
        relationId: notification.relationship&.id,
      }
    }, status: :ok
  end

  def mark_as_read
    notifications = current_user.notifications.where(id: params[:ids])

    if notifications.empty?
      render json: { error: 'Notifications not found.' }, status: :not_found
    else
      notifications.each { |n| n.update(read: true) }
      render json: { message: 'Notifications marked as read.' }, status: :ok
    end
  end

  private

  def format_time(time)
    return '' unless time

    time_in_zone = time.in_time_zone
    diff = Time.current - time_in_zone

    if diff < 60
      "#{diff.to_i}秒前"
    elsif diff < 3600
      "#{(diff / 60).to_i}分前"
    elsif diff < 86_400
      "#{(diff / 3600).to_i}時間前"
    else
      "#{(diff / 86_400).to_i}日前"
    end
  end
end
