require 'spec_helper'

describe "Tasks" do
  before do
    @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @app1 = OAuth2::Model::Client.new(:name => 'App1', :redirect_uri => 'http://localhost/')
    @app1.oauth2_client_owner_type = 'User'
    @app1.oauth2_client_owner_id = @user.id
    @app1.save!
    @app1_client_secret = @app1.client_secret
  end
  
  describe "GET /tasks/:id" do
    before do
      create_logged_in_user(@user)
      @user.tasks.create(:name => 'My Task')
      @user.tasks.first.task_items.create(:name => 'Task Item 1', :url => 'http://example.gov/1.task')
      @user.tasks.first.task_items.create(:name => 'Task Item 2', :url => 'http://example.gov/2.task')
    end
    
    it "should show saved tasks on the home page, and let a user navigate to a specific task" do
      visit root_path
      page.should have_content "Saved Task List"
      page.should have_content "My Task"
      page.should have_content "2 Forms / Possible Tasks"
      click_link("2 Forms / Possible Tasks")
      page.should have_content "My Task"
      page.should have_content "Completed at: Not Completed"
      page.should have_content "Task Item 1"
      page.should have_content "Task Item 2"
      visit dashboard_path
      click_link("Remove")
      page.should have_content "Saved Task List"
      page.should_not have_content "My Task"
    end
  end
  
  describe "POST /task" do
    context "when a valid token is passed" do
      before do
        authorization = OAuth2::Model::Authorization.new
        authorization.client = @app1
        authorization.owner = @user
        access_token = authorization.generate_access_token
        client = OAuth2::Client.new(@app1.client_id, @app1_client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
        @token = OAuth2::AccessToken.new(client, access_token)
      end
    
      context "given valid attributes" do
        it "should create a new task" do
          @user.tasks.size.should == 0
          post "/tasks", {:id => @user.id, :task => {:name => 'New Task', :task_items_attributes => [{:name => 'Task Item 1', :url => 'http://example.gov/1'}, {:name => 'Task Item 2', :url => 'http://example.gov/2'}]}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "200"
          @user.tasks.reload
          @user.tasks.size.should == 1
          @user.tasks.first.name.should == "New Task"
          @user.tasks.first.task_items.size.should == 2
          @user.tasks.first.task_items.first.name.should == 'Task Item 1'
          @user.tasks.first.task_items.last.url.should == 'http://example.gov/2'
        end
      end
    
      context "given invalid attribuates" do
        it "should return an error message" do
          @user.tasks.size.should == 0
          post "/tasks", {:id => @user.id, :task => {}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "400"
          parsed_response = JSON.parse(response.body)
          parsed_response["status"].should == "Error"
          parsed_response["message"]["name"].should == ["can't be blank"]
        end
      end
    end
    
    context "when an invalid token is passed" do
      it "should return an error message" do
        post "/tasks", {:id => @user.id, :task => {:name => 'New Task'}}, {'HTTP_AUTHORIZATION' => "Bearer fake_token"}
        response.code.should == "403"
        parsed_response = JSON.parse(response.body)
        parsed_response["status"].should == "Error"
        parsed_response["message"].should == "You do not have access to create tasks for that user."
      end
    end
  end
end
