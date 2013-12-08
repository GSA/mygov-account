class NotificationEmail
  @queue = :mailer
  def self.perform(notification_id)
    puts "**** ZOMG!!! Do something with Email with id #{notification_id}"
  end
end