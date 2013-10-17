class OauthScope < ActiveRecord::Base
  validates_presence_of :name, :scope_name, :scope_type
  validates_uniqueness_of :scope_name
  validates :scope_type, :inclusion => {:in => ["app", "user"]}
  attr_accessible :description, :name, :scope_name, :scope_type, :as => [:default, :admin]
  
  def self.seed_data
    [
      {name: 'Verify credentials', description: 'Verify application credentials', scope_name: 'verify_credentials', :scope_type => 'app'},
      {name: 'Profile', description: 'Read your profile information', scope_name: 'profile', :scope_type => 'user'},
      {name: 'Tasks', description: 'Create tasks in your account', scope_name: 'tasks', :scope_type => 'user'},
      {name: 'Notifications', description: 'Send you notifications', scope_name: 'notifications', :scope_type => 'user'}
    ]
  end
end
