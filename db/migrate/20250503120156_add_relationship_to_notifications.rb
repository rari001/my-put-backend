class AddRelationshipToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_reference :notifications, :relationship, null: true, foreign_key: true
  end
end
