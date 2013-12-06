class NotificationMailer < ActionMailer::Base
	include Resque::Mailer
  default from: "\"MyUSA\" <no-reply@my.usa.gov.>"

  def notification_email(notification_id)
  	@notification = Notification.find(notification_id)
    @email = @notification.user.email
    subject = "[MYUSA] #{@notification.app.present? ? "[#{@notification.app.name}] #{@notification.subject}" : @notification.subject}"
    mail(:to => @email, :subject => subject)
  end
end