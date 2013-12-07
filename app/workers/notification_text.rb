include ActionView::Helpers
require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'

class NotificationText

  account_sid = ENV['twilio_account_sid']
  auth_token = ENV['twilio_auth_token']
  @client = Twilio::REST::Client.new account_sid, auth_token

  @queue = :notifications
  def self.perform(notification_id)
    notification = Notification.find_by_id(notification_id)

    @client.account.messages.create(
      :from => ENV['twilio_from_number'],
      :to => '+17732699601',
      :body => "#{notification.subject} -- #{strip_tags(notification.body) if notification.body}"
    )
  end
end