require 'spec_helper'

describe App do
  before do
    @valid_attributes = {
      :name         => 'Change your name',
      :redirect_uri => 'http://www.myapp.com'
    }
  end
  
  it { should validate_presence_of(:name).with_message(/can't be blank/)}
  it { should validate_presence_of(:slug).with_message(/can't be blank/)}
  it { should validate_presence_of(:redirect_uri).with_message(/can't be blank/)}
  
  it "should validate URI format" do
    app = App.create(@valid_attributes.merge(redirect_uri: 'xyz'))
    app.errors[:redirect_uri].should include 'must be a valid URL'
    
    app = App.create(@valid_attributes.merge(url: 'xyz'))
    app.errors[:url].should include 'must be a valid URL'
  end
  
  it "should create a new app with valid attributes, and generate a unique slug" do
    app = App.create!(@valid_attributes)
    app.slug.should == app.name.parameterize
  end
  
  it "should default to the app-icon.png url" do
    app = App.create!(@valid_attributes)
    app.logo.url.should == "/assets/app-icon.png"
  end
  
  it "should remove parent scopes before saving" do
    app = App.create!(@valid_attributes)
    app.oauth_scopes << OauthScope.find_by_name("Notifications")
    app.oauth_scopes << OauthScope.find_by_name("Profile")
    app.app_oauth_scopes.count.should == 2
    app.save!
    app.app_oauth_scopes.count.should == 1
  end
  
  it "should create a new app with redirect_uri attribute" do
    App.create!(name: "one more app", redirect_uri: 'http://www.one-more-app.com').oauth2_client.redirect_uri.should == 'http://www.one-more-app.com' 
  end
  
  it "should default to not public" do
    App.create!(@valid_attributes).is_public.should be_false
  end

  it "should should compare a passed in domain to its domain and return false for a match and true for a difference" do
    app = App.create(@valid_attributes.merge(url: 'http://xyz.usa.gov'))
    App.compare_domains("https://qa.my.usa.gov/my-test-url", app.url).should == false # Domains match

    app = App.create(@valid_attributes.merge(url: 'https://ab.cd.usa.gov/my-test-url')) # .gov vs .com
    App.compare_domains("wx.yz.usa.com", app.url).should == true

    app = App.create(@valid_attributes.merge(url: 'https://qa.my.usa.gov/my-test-url')) # No public suffix in domain
    App.compare_domains("localhost", app.url).should == true

    app = App.create(@valid_attributes.merge(url: 'http://localhost:3000/my-test-url')) # No public suffix in domain
    App.compare_domains("localhost", app.url).should == false

  end
end
