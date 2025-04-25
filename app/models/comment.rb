class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  has_many :mentions, dependent: :destroy
  has_many :notifications, dependent: :destroy
end
