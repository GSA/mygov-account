class UserMailer < ActionMailer::Base
  default from: "mygov-no-reply@gsa.gov"

  def welcome_email(user)
    @user = user
    @sign_in_url = sign_in_url
    mail(:to => user.email, :subject => 'Welcome to MyGov!')
  end
end