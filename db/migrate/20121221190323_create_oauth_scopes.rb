class CreateOauthScopes < ActiveRecord::Migration
  class OauthScope < ActiveRecord::Base
    attr_accessible :name, :description, :scope_name
    def self.seed_data
      [{name: 'Profile', description: 'Read your profile information', scope_name: 'profile'},
       {name: 'Tasks', description: 'Create tasks in your account', scope_name: 'tasks'},
       {name: 'Notifications', description: 'Send you notifications', scope_name: 'notifications'},
       {name: 'Submit Forms', description: 'Submit forms on your behalf', scope_name: 'submit_forms'}]
    end
  end
  
  def change
    create_table :oauth_scopes do |t|
      t.string :name
      t.text :description
      t.string :scope_name

      t.timestamps
    end
    
    add_index :oauth_scopes, :scope_name
    
    create_table :apps_oauth_scopes, :id => false do |t|
      t.integer :app_id
      t.integer :oauth_scope_id
    end
    
    add_index :apps_oauth_scopes, :app_id
    add_index :apps_oauth_scopes, :oauth_scope_id
    
    OauthScope.reset_column_information
    OauthScope.seed_data.each { |os| OauthScope.create(os); say "Creating Oauth Scope: #{os[:name]}" }
  end
end
