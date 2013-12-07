class NotificationText
  @queue = :notifications
  def self.perform(notification_id)
    puts "**** ZOMG!!! Do something with Twilio with id #{notification_id}"
  end
end