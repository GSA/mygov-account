require 'spec_helper'

describe App do
  before do
    @valid_attributes = {
      :name         => 'Change your name',
      :redirect_uri => 'http://www.myapp.com',
      :status       => 'public'
    }
  end
  
  it { should validate_presence_of(:name).with_message(/can't be blank/)}
  it { should validate_presence_of(:slug).with_message(/can't be blank/)}
  
  it "should create a new app with valid attributes, and generate a unique slug" do
    app = App.create!(@valid_attributes)
    app.slug.should == app.name.parameterize
  end
  
  it "should default to the app-icon.png url" do
    app = App.create!(@valid_attributes)
    app.logo.url.should == "/assets/app-icon.png"
  end
  
  it "should create a new app with redirect_uri attribute" do
    App.create(name: "one more app", redirect_uri: 'http://www.one-more-app.com').oauth2_client.redirect_uri.should == 'http://www.one-more-app.com' 
  end

  it "should not be possible for a user to install a sandbox app if not the owner" do 
    # create_approved_beta_signup('joe@citizen.org')
    # @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    # @user.confirm!
    # app1 = App.create(name: 'App1', redirect_uri: "http://localhost/", status: 'sandbox', user: @user)
  end
  
end
