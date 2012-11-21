class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  validates_presence_of :subject, :received_at, :user_id
  attr_accessible :body, :received_at, :subject, :user_id, :app_id

  after_create :deliver_notification
  
  private
  
  def deliver_notification
    NotificationMailer.notification_email(self).deliver
  end
end
