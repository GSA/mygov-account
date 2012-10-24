require 'spec_helper'

describe "Messages" do
  before do
    BetaSignup.create!(:email => 'joe@citizen.org', :is_approved => true)
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @user.confirm!
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
end