class UserMailer < ActionMailer::Base
  default from: "mygov-no-reply@gsa.gov"

  def welcome_email(user)
    @user = user
    mail(:to => user.email, :subject => 'Welcome to MyGov!')
  end
end