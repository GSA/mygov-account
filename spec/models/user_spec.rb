require 'spec_helper'

describe User do
  before do
    @valid_attributes = {
      :email => 'joe@citizen.org',
      :password => 'Password1'
    }
    create_approved_beta_signup('joe@citizen.org')
  end
  
  describe "#create" do
    it "should create a new User with valid attributes" do
      User.create!(@valid_attributes)
    end

    it "should create a new User with a unique ID" do
      user = User.create!(@valid_attributes)
      user.errors.should be_empty
      user.uid.should_not be_empty
      user.uid.length.should >= 36
      User.where(:uid => user.uid).size.should == 1
    end
    
    it "should not create a user without an email" do
      user = User.create(@valid_attributes.reject{|k,v| k == :email })
      # The account should not be checked if no email address is provided
      user.errors.to_a.should_not include("I'm sorry, your account hasn't been approved yet.")
      # Should have an error for the missing email
      user.errors.should_not be_empty
    end
    
    it "should not create a user without a valid email" do
      user = User.create(@valid_attributes.merge(email: 'not_valid'))
      # The account should not be checked if no email address is provided
      user.errors.to_a.should_not include("I'm sorry, your account hasn't been approved yet.")
      # Should have an error for the invalid email
      user.errors.should_not be_empty
    end
    
    context "when no beta signup exists for the user's email" do
      before do
        BetaSignup.destroy_all
      end
      
      it "should not create the user for unapproved emails" do
        user = User.create(@valid_attributes)
        user.id.should be_nil
        user.errors.should_not be_empty
        user.errors.first.first.should == :base
        user.errors.first.last.should == "I'm sorry, your account hasn't been approved yet."
      end

      it "should create a user account for a user with a .gov email" do
        user = User.create(@valid_attributes.merge!(:email => 'leslie.knope@parks.gov'))
        user.errors.should be_empty
      end
    end
  end

  describe "confirm!" do
    before do
      @user = User.create!(@valid_attributes)
      @user.confirmation_token.should_not be_nil
    end
    
    context "when the user is confirmed" do
      before do
        @user.confirm!
      end
      
      it "should create a default notification" do
        @user.notifications.size.should == 1
        @user.notifications.first.subject.should == "Welcome to MyUSA"
      end
    end
  end
  
  describe "#find_for_open_id" do
    before do
      @access_token = Hash.new
      @access_token.stub(:provider).and_return "google"
      @access_token.stub(:uid).and_return "UID"
      @access_token.stub_chain(:info, :[]).and_return 'jane@citizen.org'
      User.destroy_all
    end
    
    context "when the user already exists" do
      before do
        user = User.create!(@valid_attributes)
        user.authentications << Authentication.new(:uid => "UID", :provider => "google")
      end
      
      it "should simply return the user" do
        User.count.should == 1
        user = User.find_for_open_id(@access_token)
        User.count.should == 1
      end
    end
    
    context "when the user does not exist" do
      before do
        User.destroy_all
        Authentication.destroy_all
        create_approved_beta_signup('jane@citizen.org')
      end

      it "should create a new user and authentication with the access token information" do
        User.count.should == 0
        Authentication.count.should == 0
        user = User.find_for_open_id(@access_token)
        user.errors.should be_empty
        User.all.last.email.should == 'jane@citizen.org'
        User.count.should == 1
        Authentication.count.should == 1
      end

    end
  end
end
