class UserMailer < ActionMailer::Base
  default from: DEFAULT_FROM_EMAIL
  
  def beta_invite(email)
    @email = email
    mail(:to => email, :subject => 'Your MyUSA Private Beta Invitation')
  end
  
  def account_deleted(email)
    @email = email
    mail(:to => email, :subject => 'Your MyUSA account has been deleted.')
  end
end
