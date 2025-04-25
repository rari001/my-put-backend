class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.references :comment, null: true, foreign_key: true # コメントが関連しない場合もあるので null: true に変更
      t.string :message
      t.boolean :read, default: false, null: false

      t.timestamps
    end
  end
end
