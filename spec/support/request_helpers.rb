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
  user = User.create!(:email => email, :password => 'Password1')
  user.confirm!
  user
end

def create_confirmed_user_with_profile(email_or_hash = {})
  email_or_hash = {email: email_or_hash} unless email_or_hash.kind_of? Hash
  profile = email_or_hash.reverse_merge(email: 'joe@citizen.org', password: 'Password1',
                                        first_name: 'Joe', last_name: 'Citizen', is_student: true)
  create_approved_beta_signup(profile[:email])
  user_create_hash = profile.select {|key,val| [:email, :password].member?(key)}
  user = User.create!(user_create_hash)
  profile_create_hash = profile.select {|key,val| Profile.new.methods.map(&:to_sym).select{ |m| m != :email }.member?(key)}
  user.profile = Profile.new(profile_create_hash)
  user.confirm!
  user
end

def get_random_password
  (0...9).map { (65 + rand(26)).chr }.join + 'a' + '1'
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

def fill_in_email_and_password(options = {})
  options = options.reverse_merge({email:'joe@citizen.org', password:'Password1'})
  fill_in 'Email', :with => options[:email]
  fill_in 'Password', :with => options[:password]
end

def lock_account
  6.times do
    fill_in 'Email', :with => 'joe@citizen.org'
    fill_in 'Password', :with => 'wordpass'
    click_button 'Sign in'
  end
end

def create_public_app_for_user(user, name = 'Public App', url = 'http://www.agency.gov/app', short_description = 'Public Application', description = 'A public application.', redirect_uri = 'http://localhost/')
  app = user.apps.create(:name => name, :url => url, :short_description => short_description, :description => description, :redirect_uri => redirect_uri)
  app.is_public = true
  app.save!
  app
end
  
