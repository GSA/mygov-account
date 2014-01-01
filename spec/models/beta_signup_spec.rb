require 'spec_helper'

describe BetaSignup do
  before do
    @valid_attributes = {
      :email => 'joe@citizen.org'
    }
    ActionMailer::Base.deliveries = []
  end
  
  it { should validate_presence_of(:email).with_message("can't be blank") }
  
  it "should create a new record given valid attributes, but not be approved, and not send an email" do
    beta_signup = BetaSignup.create!(@valid_attributes)
    should validate_uniqueness_of(:email).with_message("has already been taken")
    beta_signup.is_approved.should == false
    ActionMailer::Base.deliveries.should be_empty
  end
  
  it "should send an email after update if the sign up has been approved" do
    beta_signup = BetaSignup.create!(@valid_attributes)
    beta_signup.is_approved = true
    beta_signup.save!
    ActionMailer::Base.deliveries.size.should == 1
    email = ActionMailer::Base.deliveries.first
    email.from.should == [Mail::Address.new(DEFAULT_FROM_EMAIL).address]
    email.to.should == [beta_signup.email]
    email.subject.should =~ /MyUSA/
    email.subject.should =~ /Beta/
    email.parts.map {|part| expect(part.body).to include('Welcome to the MyUSA beta')}
  end
  
  context "when signing up with a .gov email address" do
    it "should automatically approve a signup if it's a .gov email address and send an email" do
      beta_signup = BetaSignup.create!(:email => 'test@america.gov')
      beta_signup.is_approved.should be_true
      beta_signup.save
      ActionMailer::Base.deliveries.size.should == 1
      email = ActionMailer::Base.deliveries.first
      email.parts.map {|part| expect(part.body).to include('Welcome to the MyUSA beta')}
    end
  end
  
  describe "approve!/unapprove!" do
    it "should set the user as approved when called" do
      beta_signup = BetaSignup.create!(@valid_attributes)
      beta_signup.approve!
      beta_signup.is_approved.should == true
      beta_signup.unapprove!
      beta_signup.is_approved.should == false
    end
  end
end