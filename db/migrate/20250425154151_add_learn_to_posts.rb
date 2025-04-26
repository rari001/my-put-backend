class AddLearnToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :learn, :boolean, default: false, null: false
  end
end
