class UserMailer < ActionMailer::Base
  default from: "mygov-no-reply@gsa.gov"

  def beta_welcome_email(email)
    mail(:to => email, :subject => 'Thanks for signing up for MyGov!')
  end
  
  def beta_invite(email)
    @email = email
    mail(:to => email, :subject => 'Your MyGov account is ready!')
  end
end