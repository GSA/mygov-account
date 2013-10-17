class AddScopeTypeToOauthScopes < ActiveRecord::Migration
  def change
    add_column :oauth_scopes, :scope_type, :string, :limit => 20
  end
end
