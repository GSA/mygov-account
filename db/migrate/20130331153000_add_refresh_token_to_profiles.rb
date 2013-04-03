class AddRefreshTokenToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :refresh_token, :string
  end
end
