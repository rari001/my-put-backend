class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :comment, optional: true
  belongs_to :like, optional: true  # likeとの関連を追加、optional: true でlikeがなくても通知が作成できるようにする

  validates :message, presence: true
end
