include ActionView::Helpers
require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'

class NotificationText

  account_sid = ENV['TWILIO_ACCOUNT_SID']
  auth_token = ENV['TWILIO_AUTH_TOKEN']
  @client = Twilio::REST::Client.new account_sid, auth_token

  @queue = :sms
  def self.perform(notification_id)
    notification = Notification.find_by_id(notification_id)


    @client.account.messages.create(
      :from => ENV['TWILIO_FROM_NUMBER'],
      :to => '+17732699601',
      :body => "#{notification.subject} -- #{strip_tags(notification.body) if notification.body}"
    )
  end
end