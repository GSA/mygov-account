class CreateAppOauthScopes < ActiveRecord::Migration
  def up
    create_table :app_oauth_scopes do |t|
      t.references :app
      t.references :oauth_scope

      t.timestamps
    end
    add_index :app_oauth_scopes, :app_id
    add_index :app_oauth_scopes, :oauth_scope_id
    
    App.all.each do |app|
      app.oauth_scopes.each do |scope|
        app.app_oauth_scopes.create(:oauth_scope => scope)
      end
    end
    drop_table :apps_oauth_scopes
  end
  
  def down
    create_table "apps_oauth_scopes", :id => false, :force => true do |t|
      t.integer "app_id"
      t.integer "oauth_scope_id"
    end
    add_index "apps_oauth_scopes", ["app_id"], :name => "index_apps_oauth_scopes_on_app_id"
    add_index "apps_oauth_scopes", ["oauth_scope_id"], :name => "index_apps_oauth_scopes_on_oauth_scope_id"
    
    App.all.each do |app|
      app.app_oauth_scopes.each do |scope|
        app << OauthScope.find_by_id(scope.id)
      end
    end
    
    drop_table :app_oauth_scopes
  end
end
