class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  validates_presence_of :subject, :received_at, :app_id, :user_id
  attr_accessible :body, :received_at, :subject, :user_id, :app_id
end
