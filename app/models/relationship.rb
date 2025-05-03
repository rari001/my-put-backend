class Relationship < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :following, class_name: 'User'
  has_many :notifications, dependent: :destroy
end
