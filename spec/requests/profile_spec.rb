require 'spec_helper'

describe "Profile" do
  before do
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen', :is_approved => true)
  end

  describe "GET /profile" do
    context "when using the API" do
      before do
        @app = OAuth2::Model::Client.new(:name => 'App1', :redirect_uri => 'http://localhost/')
        @app.oauth2_client_owner_type = 'User'
        @app.oauth2_client_owner_id = @user.id
        @app.save!
      end
      
      context "when the request has a valid token" do
        before do
          authorization = OAuth2::Model::Authorization.new
          authorization.client = @app
          authorization.owner = @user
          access_token = authorization.generate_access_token
          client = OAuth2::Client.new(@app.client_id, @app.client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
          @token = OAuth2::AccessToken.new(client, access_token)
        end
        
        context "when the user queried exists" do
          it "should return JSON with the profile information for the profile specificed" do
            get "/profile.json", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
            response.code.should == "200"
            parsed_json = JSON.parse(response.body)
            parsed_json["status"].should == "OK"
            parsed_json["user"]["email"].should == "joe@citizen.org"
            parsed_json["user"]["provider"].should be_nil
          end
        
          context "when the schema parameter is set" do
            it "should render the response in a Schema.org hash" do
              get "/profile.json", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
              response.code.should == "200"
              parsed_json = JSON.parse(response.body)
              parsed_json["status"].should == "OK"
              parsed_json["user"]["email"].should == "joe@citizen.org"
              parsed_json["user"]["givenName"].should == "Joe"
              parsed_json["user"]["familyName"].should == "Citizen"
              parsed_json["user"]["homeLocation"]["streetAddress"].should be_blank
            end
          end
        end
      end
      
      context "when the request does not have a valid token" do
        it "should return an error message" do
          get "/profile.json", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
          response.code.should == "403"
          parsed_json = JSON.parse(response.body)
          parsed_json["status"].should == "Error"
          parsed_json["message"].should == "You do not have access to read that user's profile."
        end
      end
    end
    
    context "when visiting the web site via a browser" do
      context "when logged in" do
        before do
          create_logged_in_user(@user)
        end

        it "should show a user their profile" do
          visit profile_path
          page.should have_content "Your MyGov Profile"
          page.should have_content "First name: Joe"
          page.should have_content "Last name: Citizen"
          page.should have_content "Edit your Profile"
        end
      
        context "editing your profile" do
          it "should update the profile with new information provided by the user" do
            visit profile_path
            click_link "Edit your Profile"
            fill_in "Middle name", :with => "Q"
            fill_in "Address", :with => "123 Evergreen Terrace"
            fill_in "City", :with => 'Springfield'
            select "Iowa", :from => 'State'
            fill_in "Zip", :with => '12345'
            fill_in "Phone", :with => '123-456-7890'
            select 'Male', :from => 'Gender'
            select 'Married', :from => "Marital status"
            click_button "Update Profile"
            page.should have_content "Middle name: Q"
            page.should have_content "Address: 123 Evergreen Terrace"
            page.should have_content "City: Springfield"
            page.should have_content "State: IA"
            page.should have_content "Zip: 12345"
            page.should have_content "Phone: 123-456-7890"
            page.should have_content "Gender: Male"
            page.should have_content "Marital status: Married"
          end
        end
      end
    end
  end
end