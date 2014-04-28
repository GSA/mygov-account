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
      user.notify_me.should == true # New user should have notify_me default to true. #50370923
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

      it "should create a user account for a user with a .mil email" do
        user = User.create(@valid_attributes.merge!(:email => 'private.benjamin@army.mil'))
        user.errors.should be_empty
      end

      it "should create a user account for a user with a usps.com email" do
        user = User.create(@valid_attributes.merge!(:email => 'themailman@usps.com'))
        user.errors.should be_empty
      end
    end
  end

  describe "#update" do
    context "when the user changes their email address" do
      let(:user) do
          user = User.create(@valid_attributes)
          user.confirm!

          user.email = 'joseph@citizen.org'
          user.save!
          user.reload
      end

      context "when the user has not yet confirmed their new address" do
        it "should keep the original email unchanged" do
          user.email.should == 'joe@citizen.org'
        end

        it "should store the new email address as unconfirmed" do
          user.unconfirmed_email.should == 'joseph@citizen.org'
        end
      end
    end
  end

  describe "confirm!" do
    let(:user) do
      user = User.create!(@valid_attributes)
      user.profile = Profile.new(:first_name => 'Joe', :last_name => 'Citizen')
      user.confirmation_token.should_not be_nil
      user
    end

    context "when the user is confirmed" do
      before do
        user.confirm!
        user.reload
      end

      context 'when it is a new account' do
        it "should create a default notification" do
          user.notifications.size.should == 1
          user.notifications.first.subject.should == "Welcome to MyUSA"
        end
      end

      context "when it is a reconfirmation of an email address" do
        before do
          user.email = 'joseph@citizen.org'
          user.save
          user.confirm!
          user.reload
        end

        it 'should send a notification about the change' do
          user.notifications.size.should == 2
          user.notifications.last.subject.should == 'You changed your email address'
        end

        context "when there is an associated BetaSignup record" do
          it "should update the BetaSignup" do
            beta_signup = BetaSignup.where(:email => 'joseph@citizen.org')
            beta_signup.should_not be_nil
          end
        end

        context 'when there is no associated BetaSignup record' do
          let(:gov_user) do
            gov_user = User.create(:email => 'joe@citizen.gov', :password => 'Password1')
            gov_user.confirm!
            gov_user
          end

          it 'should let the user change their address and confirm it' do
            gov_user.email = 'joseph@citizen.gov'
            gov_user.save

            gov_user.reload
            gov_user.confirm!

            gov_user.reload
            gov_user.email.should == 'joseph@citizen.gov'
            gov_user.unconfirmed_email.should be_nil
          end
        end
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
        @user = User.create!(@valid_attributes)
        @user.authentications << Authentication.new(:uid => "UID", :provider => "google")
      end

      it "should simply return the user" do
        User.count.should == 1
        User.find_for_open_id(@access_token).email.should == 'joe@citizen.org'
      end

      context "when the user has changed their email address" do
        before do
          @user.email = 'janet@citizen.org'
          @user.save!
          @user.confirm!
        end

        it "should still return the user" do
          User.find_for_open_id(@access_token).email.should == 'janet@citizen.org'
        end
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
        user = User.find_for_open_id(@access_token, nil, {:terms_of_service => '1'})
        user.errors.should be_empty
        User.all.last.email.should == 'jane@citizen.org'
        User.count.should == 1
        Authentication.count.should == 1
      end

    end
  end
end
