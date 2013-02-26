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
  
  describe "as_json" do
    before do
      @profile = Profile.create!(:first_name => 'Joe', :last_name => 'Citizen', :phone_number => '202-555-1212', :gender => 'male')
    end
    
    it "should output the clear text versions of the encrypted fields, and none of the encrypted fields" do
      json = @profile.as_json
      json[:first_name].should == 'Joe'
      json[:last_name].should == 'Citizen'
      json[:encrypted_first_name].should be_nil
      json[:encrypted_last_name].should be_nil
      json[:encrypted_address].should be_nil
    end
  end
end
