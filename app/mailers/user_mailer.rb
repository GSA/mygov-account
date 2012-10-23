class UserMailer < ActionMailer::Base
  default from: "\"MyGov Team\" <projectmygov@gsa.gov>"
  
  def beta_invite_a(email)
    @email = email
    mail(:to => email, :subject => 'Your MyGov Private Beta Invitation')
  end
  
  def beta_invite_b(email)
    @email = email
    mail(:to => email, :subject => 'You\'re invited to the MyGov Beta')
  end
end
