class NotificationDashboard
  @queue = :notifications
  def self.perform(notification_id)
    puts "*"*200
    puts "**** ZOMG!!! Send a dashboard email for id #{notification_id}"
  end
end