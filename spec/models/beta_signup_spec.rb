require 'spec_helper'

describe BetaSignup do
  it { should validate_presence_of(:email).with_message("blank email") }
  
  it "should create a new record given valid attributes" do
    BetaSignup.create!(:email => 'joe@citizen.org')
    should validate_uniqueness_of(:email).with_message(/duplicate email/)
  end
end
