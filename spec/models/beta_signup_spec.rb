require 'spec_helper'

describe BetaSignup do
  it { should validate_presence_of :email }
  
  it "should create a new record given valid attributes" do
    BetaSignup.create!(:email => 'joe@citizen.org')
    should validate_uniqueness_of :email
  end
end
