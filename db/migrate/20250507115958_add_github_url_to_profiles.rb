class AddGithubUrlToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :github_url, :string
  end
end
