# include ActionView::Helpers
require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'

class NotificationText
  puts "*"*50
  puts "INSIDE NotificationText"

  @queue = :sms
  def self.perform(notification_id)
    puts "/"*50
    puts "INSIDE NotificationText.perform"
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    client = Twilio::REST::Client.new account_sid, auth_token
    puts "client: #{client}"

    notification = Notification.find_by_id(notification_id)
    puts "notification: #{notification}"


    client.account.messages.create(
      :from => ENV['TWILIO_FROM_NUMBER'],
      :to => notification.user.profile.mobile_for_twilio,
      :body => "#{notification.subject} -- #{notification.body if notification.body}"
    )

    puts "/"*50
    puts "client messages: #{client.account.messages.inspect}"
  end
end