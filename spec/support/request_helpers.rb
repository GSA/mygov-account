require 'spec_helper'
include Warden::Test::Helpers

def create_logged_in_user(user)
  login(user)
  user
end

def login(user)
  login_as user, scope: :user
end

def create_confirmed_user
  create_approved_beta_signup('joe@citizen.org')
  @user = User.create!(:email => 'joe@citizen.org', :password => 'Password1')
  @user.confirm!
end

def create_approved_beta_signup(email_or_hash)
  email_or_hash = {email: email_or_hash} unless email_or_hash.kind_of? Hash
  beta_signup = BetaSignup.new(email_or_hash)
  beta_signup.is_approved = true
  beta_signup.save!
end

def have_timeout_warning_metatag
  have_xpath("//meta[@http-equiv=\"refresh\" and contains(@content, \";\") and contains(@content, \"?no_keep_alive=1\")]")
end

def create_sandbox_app(user)
  @user.apps.create(name: 'Sandboxed App', is_public: false, user_id: user.id, redirect_uri: 'http://localhost')
end