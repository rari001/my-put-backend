class Mention < ApplicationRecord
  belongs_to :comment
  belongs_to :post
  belongs_to :user
end
