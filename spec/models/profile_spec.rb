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
      @user = create_confirmed_user_with_profile
      @user.profile.update_attributes(:phone_number => '202-555-1212', :gender => 'male')
    end
    
    context "when called without any parameters" do
      it "should output the full profile in JSON" do
        json = @user.profile.as_json
        json["first_name"].should == 'Joe'
        json["last_name"].should == 'Citizen'
        json["email"].should == 'joe@citizen.org'
        json["phone_number"].should == '202-555-1212'
        json["gender"].should == 'male'
        json["mobile_number"].should be_blank
      end
    end
    
    context "when called with a scope list that includes the profile scope" do
      it "should return the full profile" do
        json = @user.profile.as_json(:scope_list => ["profile", "tasks", "notifications"])
        json["first_name"].should == 'Joe'
        json["last_name"].should == 'Citizen'
        json["email"].should == 'joe@citizen.org'
        json["phone_number"].should == '202-555-1212'
        json["gender"].should == 'male'
        json["mobile_number"].should be_blank
      end
      
      context "and there are other profile scopes as well" do
        it "should return the full profile" do
          json = @user.profile.as_json(:scope_list => ["profile", "tasks", "notifications", "profile.first_name", "profile.gender"])
          json["first_name"].should == 'Joe'
          json["last_name"].should == 'Citizen'
          json["email"].should == 'joe@citizen.org'
          json["phone_number"].should == '202-555-1212'
          json["gender"].should == 'male'
          json["mobile_number"].should be_blank
        end
      end
    end
    
    context "when called with a set of specific profile scopes" do
      it "should return only those profile fields" do
        json = @user.profile.as_json(:scope_list => ["profile.first_name", "profile.email", "profile.mobile_number"])
        json["first_name"].should == 'Joe'
        json["last_name"].should be_nil
        json["email"].should == 'joe@citizen.org'
        json["phone_number"].should be_nil
        json["gender"].should be_nil
        json["mobile_number"].should be_blank
      end
    end   
  end
end