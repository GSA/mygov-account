require 'spec_helper'

describe "Apis" do
  before do
    BetaSignup.create!(:email => 'joe@citizen.org', :is_approved => true)
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
  end

  describe "GET /api/profile" do
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
            get "/api/profile.json", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
            response.code.should == "200"
            parsed_json = JSON.parse(response.body)
            parsed_json["status"].should == "OK"
            parsed_json["user"]["email"].should == "joe@citizen.org"
            parsed_json["user"]["provider"].should be_nil
          end
        
          context "when the schema parameter is set" do
            it "should render the response in a Schema.org hash" do
              get "/api/profile.json", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
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
          get "/api/profile.json", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
          response.code.should == "403"
          parsed_json = JSON.parse(response.body)
          parsed_json["status"].should == "Error"
          parsed_json["message"].should == "You do not have access to read that user's profile."
        end
      end
    end
  end
  
  describe "POST /api/notifications" do
    before do
      BetaSignup.create!(:email => 'jane@citizen.org', :is_approved => true)
      @other_user = User.create!(:email => 'jane@citizen.org', :password => 'random', :first_name => 'Jane', :last_name => 'Citizen', :name => 'Jane Citizen')
      @app1 = OAuth2::Model::Client.new(:name => 'App1', :redirect_uri => 'http://localhost/')
      @app1.oauth2_client_owner_type = 'User'
      @app1.oauth2_client_owner_id = @user.id
      @app1.save!
      @app1_client_secret = @app1.client_secret
      @app2 = OAuth2::Model::Client.new(:name => 'App2', :redirect_uri => 'http://localhost/')
      @app2.oauth2_client_owner_type = 'User'
      @app2.oauth2_client_owner_id = @user.id
      @app2.save!
      create_logged_in_user(@user)
      1.upto(14) do |index|
        @message = Message.new(:subject => "Message ##{index}", :received_at => Time.now - 1.hour, :body => "This is message ##{index}.")
        @message.user_id = @user.id
        @message.o_auth2_model_client_id = @app1.id
        @message.save!
      end
      @other_user_message = Message.new(:subject => 'Other User Message', :received_at => Time.now - 1.hour, :body => 'This is a message for a different user.')
      @other_user_message.user_id = @other_user.id
      @other_user_message.o_auth2_model_client_id = @app1.id
      @other_app_message = Message.new(:subject => 'Other App Message', :received_at => Time.now - 1.hour, :body => 'This is a message for a different app.')
      @other_app_message.user_id = @user.id
      @other_app_message.o_auth2_model_client_id = @app1.id
      @user.messages.destroy_all
    end
    
    context "when the user has a valid token" do
      before do
        authorization = OAuth2::Model::Authorization.new
        authorization.client = @app1
        authorization.owner = @user
        access_token = authorization.generate_access_token
        client = OAuth2::Client.new(@app1.client_id, @app1_client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
        @token = OAuth2::AccessToken.new(client, access_token)
      end
    
      context "when the message attributes are valid" do
        it "should create a new message when the message info is valid" do
          @user.messages.size.should == 0
          post "/api/notifications", {:id => @user.id, :message => {:subject => 'Project MyGov', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "200"
          @user.messages.reload
          @user.messages.size.should == 1
          @user.messages.first.subject.should == "Project MyGov"
        end
      end
      
      context "when the message attributes are not valid" do
        it "should return an error message" do
          post "/api/notifications", {:id => @user.id, :message => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "400"
          parsed_response = JSON.parse(response.body)
          parsed_response["status"].should == "Error"
          parsed_response["message"]["subject"].should == ["can't be blank"]
        end
      end
    end

    context "when the user has an invalid token" do
      it "should return an error message" do
        post "/api/notifications", {:id => @user.id, :message => {:subject => 'Project MyGov', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer fake_token"}
        response.code.should == "403"
        parsed_response = JSON.parse(response.body)
        parsed_response["status"].should == "Error"
        parsed_response["message"].should == "You do not have access to send messages to that user."
      end
    end
  end
end
