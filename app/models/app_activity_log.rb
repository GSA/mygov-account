class AppActivityLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  attr_accessible :user, :app, :controller, :action, :description

  validates_presence_of :controller, :action
end
