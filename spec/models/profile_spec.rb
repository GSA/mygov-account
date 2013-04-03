require 'spec_helper'

describe Profile do
  before do
    @valid_attributes = {
      :access_token => "Access Token",
      :provider_name => "TestProvider",
      :refresh_token => "Refresh Token",
      :data => {:some => "data"}
    }
  end
  
  class TestProvider < ProfileProvider
    
    def initilialize(user_profile = nil)
      super(user_profile)
    end
    
    def first_name
      "First name!"
    end
    
    def date_of_birth
      Date.current.to_s
    end
  end
  
  it { should belong_to :user }
  
  it "should create a new instance given valid attributes" do
    Profile.create!(@valid_attributes)
  end
  
  it "should provide getters and setters for all the profile fields" do
    profile = Profile.new(:provider_name => "TestProvider")
    profile.first_name.should == "First name!"
    profile.date_of_birth.should == Date.current
  end
end
