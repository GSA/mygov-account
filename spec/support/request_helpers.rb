require 'spec_helper'
include Warden::Test::Helpers

def create_logged_in_user(user)
  login(user)
  user
end

def login(user)
  login_as user, scope: :user
end

def create_confirmed_user(email = 'joe@citizen.org')
  create_approved_beta_signup(email)
  @user = User.create!(:email => email, :password => 'Password1')
  @user.confirm!
end

def create_confirmed_user_with_profile
  create_approved_beta_signup('joe@citizen.org')
  @user = User.create!(:email => 'joe@citizen.org', :password => 'Password1')
  @user.profile = Profile.new(:first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen', :is_student => true)
  @user.confirm!
end

def create_approved_beta_signup(email_or_hash)
  email_or_hash = {email: email_or_hash} unless email_or_hash.kind_of? Hash
  beta_signup = BetaSignup.new(email_or_hash)
  beta_signup.is_approved = true
  beta_signup.save!
  beta_signup
end

def have_timeout_warning_metatag
  have_xpath("//meta[@http-equiv=\"refresh\" and contains(@content, \";\") and contains(@content, \"?no_keep_alive=1\")]")
end

def create_sandbox_app(user)
  @user.apps.create(name: 'Sandboxed App', is_public: false, user_id: user.id, redirect_uri: 'http://localhost')
end

def fill_in_email_and_password(options={email:'joe@citizen.org', password:'Password1'})
  fill_in 'Email', :with => options[:email]
  fill_in 'Password', :with => options[:password]
  fill_in 'Password confirmation', :with => options[:password]
end

def lock_account
  6.times do
    fill_in 'Email', :with => 'joe@citizen.org'
    fill_in 'Password', :with => 'wordpass'
    click_button 'Sign in'
  end
end