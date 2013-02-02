class UserMailer < ActionMailer::Base
  default from: DEFAULT_FROM_EMAIL
  
  def beta_invite_a(email)
    @email = email
    mail(:to => email, :subject => 'Your MyUSA Private Beta Invitation')
  end
  
  def beta_invite_b(email)
    @email = email
    mail(:to => email, :subject => 'You\'re invited to the MyUSA Beta')
  end
  
  def account_deleted(email)
    @email = email
    mail(:to => email, :subject => 'Your MyUSA account has been deleted.')
  end
end
