class NotificationMailer < ActionMailer::Base
  default from: DEFAULT_FROM_EMAIL

  def notification_email(notification)
    @email = notification.user.email
    @notification = notification
    subject = "[MYGOV] #{notification.app.present? ? "[#{notification.app.name}] #{notification.subject}" : notification.subject}"
    mail(:to => @email, :subject => subject)
  end
end