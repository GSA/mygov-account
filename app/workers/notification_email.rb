class NotificationEmail
  @queue = :mailer
  def self.perform(notification_id)
    NotificationMailer.notification_email(notification_id).deliver
  end
end