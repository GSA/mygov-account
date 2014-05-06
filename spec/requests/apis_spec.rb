require 'spec_helper'

describe "Apis" do

  def build_access_token(app)
    authorization = OAuth2::Model::Authorization.new
    authorization.scope = app.oauth_scopes.collect{ |s| s.scope_name }.join(" ")
    authorization.client = app.oauth2_client
    authorization.owner = @user
    authorization.save!
    authorization.generate_access_token
  end

  before do
    @user = create_confirmed_user_with_profile(is_student: nil, is_retired: false)

    @app = App.create(:name => 'App1', :redirect_uri => "http://localhost/")
    @app.oauth_scopes = OauthScope.top_level_scopes.where(:scope_type => 'user')
    @app.oauth_scopes << OauthScope.find_by_scope_name('profile.email')
  end

  describe "GET /api/credentials/verify" do
    before do
      @verify_credentials_oauth_scope = OauthScope.find_or_create_by_name(:name => 'Verify credentials', :scope_name => 'verify_credentials', :scope_type => 'app')

      @other_app = App.create(:name => 'Other App', :redirect_uri => "http://localhost")
      @other_app.oauth_scopes << OauthScope.create(:name => 'App 1 API call', :scope_name => "app_1.api_call", :scope_type => 'user')
      @other_app_access_token = build_access_token(@other_app)
    end

    context "when the app does not have a valid token" do
      it "should return an error" do
        get "/api/credentials/verify", {:access_token => @other_app_access_token, :scope => "app_1.api_call"}, {'HTTP_AUTHORIZATION' => "Bearer BADTOKEN"}
        response.code.should == "401"
        parsed_json = JSON.parse(response.body)
        parsed_json["message"].should == "Invalid token"
      end
    end

    context "when the app has a valid access token, but does not have permission to verify credentials" do
      before do
        @app_access_token = build_access_token(@app)
      end

      it "should return an error message that informs the caller that they do not have the appropriate permissions" do
        get "/api/credentials/verify", {:access_token => @other_app_access_token, :scope => "app_1.api_call"}, {'HTTP_AUTHORIZATION' => "Bearer #{@app_access_token}"}
        response.code.should == "403"
        parsed_json = JSON.parse(response.body)
        parsed_json["message"].should == "You do not have permission to verify other application's credentials."
      end
    end

    context "when the app has permission to verify credentials" do
      before do
        @app.oauth_scopes << @verify_credentials_oauth_scope
        @app_access_token = build_access_token(@app)
      end

      context "when the app attempts to verify credentials with an invalid scope" do
        it "should return an error" do
          get "/api/credentials/verify", {:access_token => @other_app_access_token, :scope => "INVALID.SCOPE"}, {'HTTP_AUTHORIZATION' => "Bearer #{@app_access_token}"}
          response.code.should == "400"
          parsed_json = JSON.parse(response.body)
          parsed_json["message"].should == "The scope you are requesting to validate is not a recognized MyUSA scope; you may need to register your scope with MyUSA."
        end
      end

      context "when the app attempts to verify credentials with an access token that is invalid" do
        it "should return an error" do
          get "/api/credentials/verify", {:access_token => "INVALID TOKEN", :scope => "app_1.api_call"}, {'HTTP_AUTHORIZATION' => "Bearer #{@app_access_token}"}
          response.code.should == "400"
          parsed_json = JSON.parse(response.body)
          parsed_json["message"].should == "The access token you attempting to verify is not a valid access token."
        end
      end

      context "when the app attempts to verify credentials for a valid access token, but the access token does not have permission for the requested scope" do
        before do
          @other_app.oauth_scopes.destroy_all
          @other_app_access_token = build_access_token(@other_app)
        end

        it "should return an error" do
          get "/api/credentials/verify", {:access_token => @other_app_access_token, :scope => "app_1.api_call"}, {'HTTP_AUTHORIZATION' => "Bearer #{@app_access_token}"}
          response.code.should == "403"
          parsed_json = JSON.parse(response.body)
          parsed_json["message"].should == "The requesting application does not have access to app 1 api call for that user."
        end
      end

      context "when the app attempts to verify a valid access token and scope" do
        it "should return a valid response" do
          get "/api/credentials/verify", {:access_token => @other_app_access_token, :scope => "app_1.api_call"}, {'HTTP_AUTHORIZATION' => "Bearer #{@app_access_token}"}
          response.code.should == "200"
          parsed_json = JSON.parse(response.body)
          parsed_json.should be_empty
        end
      end
    end
  end

  describe "GET /api/profile" do
    before do
      @token = build_access_token(@app)
    end

    context "when the request has a valid token" do

      context "when the app does not have permission to read the user's profile" do
        before do
          @app.oauth_scopes.destroy_all
          @token = build_access_token(@app)
        end

        it "should return an error and message" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          response.code.should == "403"
          parsed_json = JSON.parse(response.body)
          parsed_json["message"].should == "You do not have permission to read that user's profile."
        end
      end

      context "when app has limited scope" do
        before do
          @limited_scope_app = App.create(:name => 'app_limited', :redirect_uri => "http://localhost/")
          @limited_scope_app.oauth_scopes = OauthScope.top_level_scopes.where(:scope_type => 'user')
          # Adding just one profile sub scope to test that only this one is presnt in json.
          @limited_scope_app.oauth_scopes << OauthScope.find_by_scope_name("profile.first_name")
          @token = build_access_token(@limited_scope_app)
        end

        it "should return JSON with only app requested user profile attritues in addition to an id and a unique identifier" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          response.code.should == "200"
          parsed_json = JSON.parse(response.body)
          parsed_json.should_not be_nil
          parsed_json["first_name"].should eq 'Joe'
          parsed_json["id"].should_not be_nil
          parsed_json["uid"].should_not be_nil
          parsed_json["email"].should be_nil  # profile.first_name is the only profile subscope app is authorized to access.
          # ...
          parsed_json["is_veteran"].should be_nil  # profile.first_name is the only profile subscope app is authorized to access.
          parsed_json["is_retired"].should be_nil  # profile.first_name is the only profile subscope app is authorized to access.
        end
      end

      context "when app has all scopes" do
        before do
          @all_scopes_app = App.create(:name => 'app_all_scopes', :redirect_uri => "http://localhost/")
          @all_scopes_app.oauth_scopes = OauthScope.top_level_scopes.where(:scope_type => 'user')
          # Adding just one profile sub scope to test that only this one is presnt in json.
          @all_scopes_app.oauth_scopes.concat OauthScope.where("scope_name like ?", 'profile.%').all
          @token = build_access_token(@all_scopes_app)
        end
        it "should return JSON with only app requested user profile attritues in addition to an id and a unique identifier" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          response.code.should == "200"
          parsed_json = JSON.parse(response.body)
          parsed_json.should_not be_nil
          parsed_json["first_name"].should eq 'Joe'
          parsed_json["id"].should_not be_nil
          parsed_json["uid"].should_not be_nil
          parsed_json["email"].should_not be_nil
          # ...
          parsed_json["is_veteran"].should be_nil # we did not specify a value for this
          parsed_json["is_retired"].should eq false
        end
      end

      context "when the user queried exists" do
        it "should log the profile request" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          log = AppActivityLog.find(:all, :order => :created_at).last
          log.action.should == "show"
          log.controller.should == "profiles"
          log.app.name.should == "App1"
          log.user.email.should == "joe@citizen.org"
        end

        context "when the schema parameter is set" do
          it "should render the response in a Schema.org hash" do
            get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            response.code.should == "200"
            parsed_json = JSON.parse(response.body)
            parsed_json.should_not be_nil
            parsed_json["email"].should == 'joe@citizen.org'
          end
        end
      end
    end

    context "when the request does not have a valid token" do
      it "should return an error message" do
        get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        response.code.should == "401"
        parsed_json = JSON.parse(response.body)
        parsed_json["message"].should == "Invalid token"
      end
    end
  end

  describe "POST /api/notifications" do
    before do
      @token = build_access_token(@app)
      @other_user = create_confirmed_user_with_profile(email: 'jane@citizen.org', first_name: 'Jane')
      @app2 = App.create!(:name => 'App2', :redirect_uri => "http://localhost:3000/")
      @app2.oauth_scopes << OauthScope.top_level_scopes
      login(@user)
      1.upto(14) do |index|
        @notification = Notification.create!({:subject => "Notification ##{index}", :received_at => Time.now - 1.hour, :body => "This is notification ##{index}.", :user_id => @user.id, :app_id => @app.id}, :as => :admin)
      end
      @other_user_notification = Notification.create!({:subject => 'Other User Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different user.', :user_id => @other_user.id, :app_id => @app.id}, :as => :admin)
      @other_app_notification = Notification.create!({:subject => 'Other App Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different app.', :user_id => @user.id, :app_id => @app2.id}, :as => :admin)
      @user.notifications.each{ |n| n.destroy(:force) }
      @user.notifications.reload
    end

    context "when the user has a valid token" do
      context "when the notification attributes are valid" do
        it "should create a new notification when the notification info is valid" do
          @user.notifications.size.should == 0
          post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          response.code.should == "200"
          @user.notifications.reload
          @user.notifications.size.should == 1
          @user.notifications.first.subject.should == "Project MyUSA"
        end
      end

      context "when the notification attributes are not valid" do
        it "should return an error message" do
          post "/api/notifications", {:notification => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          response.code.should == "400"
          parsed_response = JSON.parse(response.body)
          parsed_response["message"]["subject"].should == ["can't be blank"]
        end
      end
    end

    context "when the the app does not have the proper scope" do
      before do
        @app3 = App.create(:name => 'App3', :redirect_uri => "http://localhost/")
        @app3.oauth_scopes << OauthScope.find_by_scope_name('tasks')
        @token3 = build_access_token(@app3)
      end

      it "should return an error message" do
        post "/api/notifications", {:notification => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token3}"}
        response.code.should == "403"
        parsed_json = JSON.parse(response.body)
        parsed_json["message"].should == "You do not have permission to send notifications to that user."
      end
    end

    context "when the user has an invalid token" do
      it "should return an error message" do
        post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer fake_token"}
        response.code.should == "401"
        parsed_response = JSON.parse(response.body)
        parsed_response["message"].should == "Invalid token"
      end
    end
  end

  describe "Tasks API" do
    before do
      @token = build_access_token(@app)
    end

    describe "GET /api/tasks.json" do
      context "when token is valid" do
        context "when there are tasks for a user, some of which were created by the app making the request" do
          before do
            @task1 = Task.create!({:name => 'Task #1', :user_id => @user.id, :app_id => @app.id}, :as => :admin)
            @task1.task_items << TaskItem.create!(:name => 'Task item 1 (no url)')
            @task2 = Task.create!({:name => 'Task #2', :user_id => @user.id, :app_id => @app.id + 1}, :as => :admin)
            @task2.task_items << TaskItem.create!(:name => 'Task item 1 (with url)', :url => 'http://www.google.com')
          end

          it "should return the tasks that were created by the calling app" do
            get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}" }
            response.code.should == "200"
            parsed_json = JSON.parse(response.body)
            parsed_json.size.should == 1
            parsed_json.first["name"].should == "Task #1"
          end

          it "should return the task and task items" do
            get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}" }
            parsed_json = JSON.parse(response.body)
            parsed_json.first['task_items'].first['name'].should == "Task item 1 (no url)"
          end
        end
      end

      context "when the the app does not have the proper scope" do
        before do
          @app4 = App.create(:name => 'App4', :redirect_uri => "http://localhost/")
          @app4.oauth_scopes << OauthScope.find_by_scope_name('notifications')
          @token4 = build_access_token(@app4)
        end

        it "should return an error message" do
          get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token4}"}
          response.code.should == "403"
          parsed_json = JSON.parse(response.body)
          parsed_json["message"].should == "You do not have permission to view tasks for that user."
        end
      end

      context "when the request does not have a valid token" do
        it "should return an error message" do
          get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
          response.code.should == "401"
          parsed_json = JSON.parse(response.body)
          parsed_json["message"].should == "Invalid token"
        end
      end
    end

    describe "POST /api/tasks" do
      context "when the caller has a valid token" do
        context "when the appropriate parameters are specified" do
          it "should create a new task for the user" do
            post "/api/tasks", {:task => { :name => 'New Task' }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            response.code.should == "200"
            parsed_json = JSON.parse(response.body)
            parsed_json.should_not be_nil
            parsed_json["name"].should == "New Task"
            Task.find_all_by_name_and_user_id_and_app_id('New Task', @user.id, @app.id).should_not be_nil
          end
        end

        context "when the required parameters are missing" do
          it "should return an error message" do
            post "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            response.code.should == "400"
            parsed_json = JSON.parse(response.body)
            parsed_json["message"].should == {"name"=>["can't be blank"]}
          end
        end
      end

      context "when the request does not have a valid token" do
        it "should return an error message" do
          post "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
          response.code.should == "401"
          parsed_json = JSON.parse(response.body)
          parsed_json["message"].should == "Invalid token"
        end
      end
    end

    describe "PUT /api/tasks:id.json" do
      context "when the caller has a valid token" do
        before do
          @task = Task.create!({:name => "Mega task", :completed_at => Time.now-1.day, :user_id => @user.id, :app_id => @app.id, :task_items_attributes => [{ :name => "Task item one" }]}, :as =>:admin)
        end
        context "when valid parameters are used" do
          it "should update the task and task items" do
            put "/api/tasks/#{@task.id}", {:task => { :name => 'New Task' , :task_items_attributes => [{ :id => @task.task_items.first.id, :name => "new task item one" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            response.code.should == "200"
            parsed_json = JSON.parse(response.body)
            parsed_json['name'].should == "New Task"
            parsed_json['task_items'].first['name'].should == 'new task item one'
          end
        end

        context "when updating a task marked as completed" do
           before do
            @task = Task.create!({:name => "Mega completed task", :user_id => @user.id, :app_id => @app.id, :task_items_attributes => [{ :name => "Task item one" }]}, :as =>:admin)
            @task.complete!
          end
          it "should no longer be marked as complete when specified" do
            put "/api/tasks/#{@task.id}", {:task => { :name => 'New Incomplete Task', :completed_at => nil, :task_items_attributes => [{ :id => @task.task_items.first.id, :name => "new task item one" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            response.code.should == "200"
            parsed_json = JSON.parse(response.body)
            parsed_json['name'].should == "New Incomplete Task"
            parsed_json['task_items'].first['name'].should == 'new task item one'
          end
        end

        context "when invalid parameters are used" do
          it "should return meaningful errors" do
            put "/api/tasks/#{@task.id}", {:task => { :name => 'New Task' , :task_items_attributes => [{ :id => "chicken", :name => "updated task item name" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            response.code.should == "422"
            parsed_json = JSON.parse(response.body)
            parsed_json['message'].should == "Invalid parameters. Check your values and try again."
          end
        end
      end

      context "when the caller does not have a valid token" do
        before do
          @task = Task.create!({:name => "Super task", :user_id => @user.id, :app_id => @app.id, :task_items_attributes => [{ :name => "Task item one" }]}, :as =>:admin)
        end

        it "should return authorization error" do
          put "/api/tasks/#{@task.id}", {:task => { :name => 'New Task' , :task_items_attributes => [{ :id => @task.task_items.first.id, :name => "new task item one" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}_"}
          response.code.should == "401"
          parsed_json = JSON.parse(response.body)
          parsed_json["message"].should == "Invalid token"
        end
      end
    end

    describe "GET /api/tasks/:id.json" do
      before do
        @task = Task.create!({:name => 'New Task', :user_id => @user.id, :app_id => @app.id}, :as => :admin)
        @task.task_items << TaskItem.new(:name => "Task Item #1")
        @task.task_items << TaskItem.new(:name => "Task Item #2", :url => 'http://valid_url.com')
        @task.save!
      end

      context "when the token is valid" do
        it "should retrieve the task" do
          get "/api/tasks/#{@task.id}", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          response.code.should == "200"
          parsed_json = JSON.parse(response.body)
          parsed_json.should_not be_nil
          parsed_json["name"].should == "New Task"
          parsed_json["task_items"].first["name"].should eq "Task Item #1"
          parsed_json["task_items"].last["url"].should eq "http://valid_url.com"
        end
      end

      context "when the request does not have a valid token" do
        it "should return an error message" do
          get "/api/tasks/#{@task.id}", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
          response.code.should == "401"
          parsed_json = JSON.parse(response.body)
          parsed_json["message"].should == "Invalid token"
        end
      end
    end
  end
end
