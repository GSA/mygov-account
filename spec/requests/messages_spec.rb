require 'spec_helper'

describe "Messages" do
  before do
    @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @other_user = User.create!(:email => 'jane@citizen.org', :first_name => 'Jane', :last_name => 'Citizen', :name => 'Jane Citizen')
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
  end

  describe "GET /messages" do
    it "should display a paginated list of user's messages" do
      visit messages_path
      1.upto(10) do |index|
        page.should have_content "Message ##{index}"
      end
      page.should_not have_content "Message #11"
      page.should_not have_content "Other User Message"
      page.should_not have_content "Other App Message"
      click_link('2')
      2.upto(10) do |index|
        page.should_not have_content "Message ##{index}"
      end
      11.upto(14) do |index|
        page.should have_content "Message ##{index}"
      end
      click_link('Delete')
      page.should_not have_content "Message #9"
      page.should_not have_content "Message #11"
    end
  end
  
  describe "GET /message/:id" do
    it "should show the message in detail and allow the user to delete it" do
      visit messages_path
      click_link "Message #9"
      page.should have_content "Message #9"
      page.should have_content "This is message #9"
      click_link "Delete"
      page.should have_content "Message #2"
      page.should_not have_content "Message #9"
    end
  end
  
  describe "POST /messages" do
    before do
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
          post "/messages", {:id => @user.id, :message => {:subject => 'Project MyGov', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          @user.messages.reload
          @user.messages.size.should == 1
          @user.messages.first.subject.should == "Project MyGov"
        end
      end
      
      context "when the message attributes are not valid" do
        it "should return an error message" do
          post "/messages", {:id => @user.id, :message => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          parsed_response = JSON.parse(response.body)
          parsed_response["status"].should == "Error"
          parsed_response["message"]["subject"].should == ["can't be blank"]
        end
      end
    end
  end
  
  context "when the user has an invalid token" do
    it "should return an error message" do
      post "/messages", {:id => @user.id, :message => {:subject => 'Project MyGov', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer fake_token"}
      parsed_response = JSON.parse(response.body)
      parsed_response["status"].should == "Error"
      parsed_response["message"].should == "You do not have access to send messages to that user."
    end
  end
end