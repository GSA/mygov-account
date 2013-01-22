require 'spec_helper'

describe App do
  before do
    @valid_attributes = {
      :name => 'Change your name'
    }
  end
  
  it { should validate_presence_of(:name).with_message(/can't be blank/)}
  it { should validate_presence_of(:slug).with_message(/can't be blank/)}
  
  it "should create a new app with valid attributes, and generate a unique slug" do
    app = App.create!(@valid_attributes){|app| app.redirect_uri = "http://localhost:3000/"}
    app.slug.should == app.name.parameterize
  end
  
  it "should default to the app-icon.png url" do
    app = App.create!(@valid_attributes){|app| app.redirect_uri = "http://localhost:3000/"}
    app.logo.url.should == "/assets/app-icon.png"
  end
  
  it "should create a new app with redirect_uri attribute" do
    App.create(name: "one more app", redirect_uri: 'http://www.one-more-app.com').oauth2_client.redirect_uri.should == 'http://www.one-more-app.com' 
  end
end
