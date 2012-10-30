require 'spec_helper'

describe Notification do
  before do
    @valid_attributes = {
      :subject => 'Test',
      :received_at => Time.now,
      :body => 'This is a test notification'
    }
    BetaSignup.create!(:email => 'joe@citizen.org', :is_approved => true)
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @app = App.create!(:name => 'App1'){ |app| app.redirect_uri = 'http://localhost/' }
  end
  
  it { should validate_presence_of :subject }
  it { should validate_presence_of :received_at }
  it { should validate_presence_of :app_id }
  it { should validate_presence_of :user_id }
  it { should belong_to :user }
  it { should belong_to :app }
  
  it "should create a new notification with valid attributes" do
    notification = Notification.create!(@valid_attributes.merge(:user_id => @user.id, :app_id => @app.id))
  end  
end