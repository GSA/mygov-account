require 'spec_helper'

describe User do
  before do
    @valid_attributes = {
      :email => 'citizen@mygov.gov',
      :password => 'random',
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
    
    it "should strip all dashes out of phone numbers" do
      User.create!(@valid_attributes.merge(:phone_number => '123-456-7890')).phone.should == '1234567890'
    end
    
    it "should strip all dashes out of mobile numbers" do
      User.create!(@valid_attributes.merge(:mobile_number => '123-456-7890')).mobile.should == '1234567890'
    end
    
    it "should strip dashes out of phone and mobile numbers on updates" do
      user = User.create!(@valid_attributes.merge(:phone_number => '123-456-7890'))
      user.update_attributes(:phone_number => '123-567-4567', :mobile_number => '3-45-678-9012')
      user.phone.should == '1235674567'
      user.mobile.should == '3456789012'
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
