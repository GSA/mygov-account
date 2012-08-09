require 'spec_helper'

describe User do
  before do
    @valid_attributes = {
      :email => 'citizen@mygov.gov',
      :name => 'Joe Citizen',
      :first_name => 'Joe',
      :last_name => 'Citizen'
    }
  end
  
  describe "#create" do
    
    it "should create a new User with valid attributes" do
      User.create!(@valid_attributes)
    end
    
    it "should not create a user without an email" do
      user = User.create(@valid_attributes.reject{|k,v| k == :email })
      user.errors.should_not be_empty
    end
  end
  
  describe "#find_for_open_id" do
    before do
      @access_token = mock(Object)
      @access_token.stub!(:provider).and_return "google"
      @access_token.stub!(:uid).and_return "UID"
      @access_token.stub(:info).and_return @valid_attributes.stringify_keys
      User.destroy_all
    end
    
    context "when the user already exists" do
      before do
        User.create!(@valid_attributes)
      end
      
      it "should simply return the user" do
        User.count.should == 1
        user = User.find_for_open_id(@access_token)
        User.count.should == 1
      end
    end
    
    context "when the user does not exist" do
      it "should create a new user with the access token information" do
        User.count.should == 0
        user = User.find_for_open_id(@access_token)
        user.errors.should be_empty
        User.count.should == 1
      end
    end
  end
end
