class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :post, optional: true
  belongs_to :comment, optional: true
  belongs_to :like, optional: true  # likeとの関連を追加、optional: true でlikeがなくても通知が作成できるようにする
  belongs_to :relationship, optional: true

  validates :message, presence: true
end
