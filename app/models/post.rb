class Post < ApplicationRecord
  validates :content, presence: true
  # validates :images, presence: true
  # has_many_attached :images
end
