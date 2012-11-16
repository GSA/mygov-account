require 'spec_helper'

describe "Apis" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @user.confirm!
    @app = App.create(:name => 'App1'){ |app| app.redirect_uri = 'http://localhost/' }
    authorization = OAuth2::Model::Authorization.new
    authorization.client = @app.oauth2_client
    authorization.owner = @user
    access_token = authorization.generate_access_token
    client = OAuth2::Client.new(@app.oauth2_client.client_id, @app.oauth2_client.client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
    @token = OAuth2::AccessToken.new(client, access_token)
  end

  describe "GET /api/profile" do
    context "when the request has a valid token" do
      context "when the user queried exists" do
        it "should return JSON with the profile information for the profile specificed" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "200"
          parsed_json = JSON.parse(response.body)
          parsed_json["status"].should == "OK"
          parsed_json["user"]["email"].should == "joe@citizen.org"
          parsed_json["user"]["provider"].should be_nil
        end
      
        context "when the schema parameter is set" do
          it "should render the response in a Schema.org hash" do
            get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
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
        get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        response.code.should == "403"
        parsed_json = JSON.parse(response.body)
        parsed_json["status"].should == "Error"
        parsed_json["message"].should == "You do not have access to read that user's profile."
      end
    end
  end
  
  describe "POST /api/notifications" do
    before do
      create_approved_beta_signup('jane@citizen.org')
      @other_user = User.create!(:email => 'jane@citizen.org', :password => 'random', :first_name => 'Jane', :last_name => 'Citizen', :name => 'Jane Citizen')
      @app2 = App.create!(:name => 'App2'){|app| app.redirect_uri = "http://localhost:3000/"}
      create_logged_in_user(@user)
      1.upto(14) do |index|
        @notification = Notification.create!(:subject => "Notification ##{index}", :received_at => Time.now - 1.hour, :body => "This is notification ##{index}.", :user_id => @user.id, :app_id => @app.id)
      end
      @other_user_notification = Notification.create!(:subject => 'Other User Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different user.', :user_id => @other_user.id, :app_id => @app.id)
      @other_app_notification = Notification.create!(:subject => 'Other App Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different app.', :user_id => @user.id, :app_id => @app2.id)
      @user.notifications.each{ |n| n.destroy(:force) } #destroy_all does soft delete, must use force to hard delete
      @user.notifications.reload #Update collection after hard deleting. 
    end
    
    context "when the user has a valid token" do    
      context "when the notification attributes are valid" do
        it "should create a new notification when the notification info is valid" do
          @user.notifications.size.should == 0
          post "/api/notifications", {:notification => {:subject => 'Project MyGov', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "200"
          @user.notifications.reload
          @user.notifications.size.should == 1
          @user.notifications.first.subject.should == "Project MyGov"
        end
      end
      
      context "when the notification attributes are not valid" do
        it "should return an error message" do
          post "/api/notifications", {:notification => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "400"
          parsed_response = JSON.parse(response.body)
          parsed_response["status"].should == "Error"
          parsed_response["message"]["subject"].should == ["can't be blank"]
        end
      end
    end

    context "when the user has an invalid token" do
      it "should return an error message" do
        post "/api/notifications", {:notification => {:subject => 'Project MyGov', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer fake_token"}
        response.code.should == "403"
        parsed_response = JSON.parse(response.body)
        parsed_response["status"].should == "Error"
        parsed_response["message"].should == "You do not have access to send notifications to that user."
      end
    end
  end

  describe "GET /api/tasks.json" do
    context "when token is valid" do
      context "when there are notifications for a user, some of which were created by the app making the request" do
        before do
          @task1 = Task.create!(:name => 'Task #1', :user_id => @user.id, :app_id => @app.id)
          @task2 = Task.create!(:name => 'Task #2', :user_id => @user.id, :app_id => @app.id + 1)
        end
      
        it "should return the tasks that were created by the calling app" do
          get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}" }
          response.code.should == "200"
          parsed_json = JSON.parse(response.body)
          parsed_json.size.should == 1
          parsed_json.first["name"].should == "Task #1"
        end
      end
    end
    
    context "when the request does not have a valid token" do
      it "should return an error message" do
        get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        response.code.should == "403"
        parsed_json = JSON.parse(response.body)
        parsed_json["status"].should == "Error"
        parsed_json["message"].should == "You do not have access to view tasks for that user."
      end
    end
  end
  
  describe "POST /api/tasks" do
    context "when the caller has a valid token" do
      context "when the appropriate parameters are specified" do
        it "should create a new task for the user" do
          post "/api/tasks", {:task => { :name => 'New Task' }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}" }
          response.code.should == "200"
          parsed_json = JSON.parse(response.body)
          parsed_json["status"].should == "OK"
          parsed_json["task"].should_not be_nil
          parsed_json["task"]["name"].should == "New Task"
          Task.find_all_by_name_and_user_id_and_app_id('New Task', @user.id, @app.id).should_not be_nil
        end
      end
      
      context "when the required parameters are missing" do
        it "should return an error message" do
          post "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}" }
          response.code.should == "400"
          parsed_json = JSON.parse(response.body)
          parsed_json["status"].should == "Error"
          parsed_json["message"].should == {"name"=>["can't be blank"]}
        end
      end
    end
    
    context "when the request does not have a valid token" do
      it "should return an error message" do
        post "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        response.code.should == "403"
        parsed_json = JSON.parse(response.body)
        parsed_json["status"].should == "Error"
        parsed_json["message"].should == "You do not have access to create tasks for that user."
      end
    end
  end
  
  describe "GET /api/tasks/:id.json" do
    before do
      @task = Task.create!(:name => 'New Task', :user_id => @user.id, :app_id => @app.id)
    end
    
    context "when the token is valid" do
      it "should retrieve the task" do
        get "/api/tasks/#{@task.id}", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
        response.code.should == "200"
        parsed_json = JSON.parse(response.body)
        parsed_json.should_not be_nil
        parsed_json["name"].should == "New Task"
      end
    end
    
    context "when the request does not have a valid token" do
      it "should return an error message" do
        get "/api/tasks/#{@task.id}", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        response.code.should == "403"
        parsed_json = JSON.parse(response.body)
        parsed_json["status"].should == "Error"
        parsed_json["message"].should == "You do not have access to view tasks for that user."
      end
    end
  end
end