class OauthScope < ActiveRecord::Base
  attr_accessible :description, :name, :scope_name
  has_and_belongs_to_many :apps
  
  validates_presence_of :name, :scope_name
  validates_uniqueness_of :scope_name
  
  def self.seed_data
    [{name: 'Profile', description: 'Read your profile information', scope_name: 'profile'},
     {name: 'Tasks', description: 'Create tasks in your account', scope_name: 'tasks'},
     {name: 'Notifications', description: 'Send you notifications', scope_name: 'notifications'},
     {name: 'Submit Forms', description: 'Submit forms on your behalf', scope_name: 'submit_forms'}]
  end
end
