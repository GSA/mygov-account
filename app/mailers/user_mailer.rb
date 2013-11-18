class UserMailer < ActionMailer::Base
  include Resque::Mailer
  default from: DEFAULT_FROM_EMAIL
  
  def beta_invite(email)
    @email = email
    mail(:to => email, :subject => 'Your MyUSA Private Beta Invitation')
  end
  
  def account_deleted(email)
    @email = email
    mail(:to => email, :subject => 'Your MyUSA account has been deleted')
  end
  
  def reset_password_confirmation(email)
    @email = email
    mail(to: email, subject: 'Your MyUSA password has been changed')
  end
  
end
