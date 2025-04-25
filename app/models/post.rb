class Post < ApplicationRecord
  validates :content, presence: true

  belongs_to :user
  has_one_attached :avatar
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :stocks, dependent: :destroy
end
