class AddScopeTypeToOauthScopes < ActiveRecord::Migration
  def change
    add_column :oauth_scopes, :scope_type, :string, :limit => 20
    OauthScope.all.each{|os| scope_type = (os.scope_name == "verify_credentials" ? 'app' : 'user'); os.update_attributes!(scope_type: scope_type) }
    say "#{OauthScope.count} scope records updated."
  end
end
