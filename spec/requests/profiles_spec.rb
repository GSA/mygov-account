require 'spec_helper'

describe "Profiles" do
  before do
    @user = User.create(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :provider => 'google')
  end
  
  describe "GET /profiles/:id.json" do
    context "when the user queried exists" do
      it "should return JSON with the profile information for the profile specificed" do
        get "/profiles/#{@user.id}.json"
        parsed_json = JSON.parse(response.body)
        parsed_json["status"].should == "OK"
        parsed_json["user"]["email"].should == "joe@citizen.org"
        parsed_json["user"]["provider"].should be_nil
      end
    end
    
    context "when the user does not exist" do
      it "should return an error message" do
        get "/profiles/#{@user.id + 1}.json"
        parsed_json = JSON.parse(response.body)
        parsed_json["status"].should == "Error"
        parsed_json["message"].should == "Profile not found"
      end
    end 
  end
end
