require 'spec_helper'

describe Profile do
  before do
    @valid_attributes = {
      :first_name => 'Joe',
      :last_name => 'Citizen'
    }
  end

  it "should strip all dashes out of phone numbers" do
    Profile.create!(@valid_attributes.merge(:phone_number => '123-456-7890')).phone.should == '1234567890'
  end
  
  it "should strip all dashes out of mobile numbers" do
    Profile.create!(@valid_attributes.merge(:mobile_number => '123-456-7890')).mobile.should == '1234567890'
  end
  
  it "should strip dashes out of phone and mobile numbers on updates" do
    profile = Profile.create!(@valid_attributes.merge(:phone_number => '123-456-7890'))
    profile.update_attributes(:phone_number => '123-567-4567', :mobile_number => '3-45-678-9012')
    profile.phone.should == '1235674567'
    profile.mobile.should == '3456789012'
  end
  
  it "should reject zip codes that aren't five digits" do
    profile = Profile.create(@valid_attributes.merge(:zip => "Greg"))
    profile.id.should be_nil
    profile.errors.messages[:zip].should == ["should be in the form 12345"]
  end
end
