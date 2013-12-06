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
    create_confirmed_user_with_profile

    @app = App.create(:name => 'App1', :redirect_uri => "http://localhost/")
    @app.oauth_scopes = OauthScope.where(:scope_type => 'user')
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
      context "when the user queried exists" do
        it "should return JSON with a user profile with email and unique ID" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          response.code.should == "200"
          parsed_json = JSON.parse(response.body)
          parsed_json.should_not be_nil
          parsed_json["email"].should == 'joe@citizen.org'
          parsed_json["id"].should_not be_nil
          parsed_json.reject{|k,v| k == "email" or k == "id" or k == "uid"}.each do |key, value|
            parsed_json[key].should be_nil
          end
        end

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
    end

    before do
      create_approved_beta_signup('jane@citizen.org')
      @other_user = User.create!(:email => 'jane@citizen.org', :password => 'Password1')
      @other_user.profile = Profile.new(:first_name => 'Jane', :last_name => 'Citizen', :name => 'Jane Citizen')
      @app2 = App.create!(:name => 'App2', :redirect_uri => "http://localhost:3000/")
      @app2.oauth_scopes << OauthScope.all
      login(@user)
      1.upto(14) do |index|
        @notification = Notification.create!({:subject => "Notification ##{index}", :received_at => Time.now - 1.hour, :body => "This is notification ##{index}.", :user_id => @user.id, :app_id => @app.id, :identifier => 'myapp-identifier'}, :as => :admin)
      end
      @other_user_notification = Notification.create!({:subject => 'Other User Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different user.', :user_id => @other_user.id, :app_id => @app.id, :identifier => 'myuser-identifier'}, :as => :admin)
      @other_app_notification = Notification.create!({:subject => 'Other App Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different app.', :user_id => @user.id, :app_id => @app2.id, :identifier => 'myapp2-identifier'}, :as => :admin)
      @user.notifications.each{ |n| n.destroy(:force) }
      @user.notifications.reload
    end

    context "when the user has a valid token" do
      context "when the notification attributes are valid" do
        it "should create a new notification when the notification info is valid" do
          @user.notifications.size.should == 0
          post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.', :identifier => 'myapp-identifier'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
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
        @app3.oauth_scopes << OauthScope.find_by_scope_name("tasks")
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
        context "when there are notifications for a user, some of which were created by the app making the request" do
          before do
            @task1 = Task.create!({:name => 'Task #1', :user_id => @user.id, :app_id => @app.id}, :as => :admin)
            @task2 = Task.create!({:name => 'Task #2', :user_id => @user.id, :app_id => @app.id + 1}, :as => :admin)
          end

          it "should return the tasks that were created by the calling app" do
            get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}" }
            response.code.should == "200"
            parsed_json = JSON.parse(response.body)
            parsed_json.size.should == 1
            parsed_json.first["name"].should == "Task #1"
          end
        end
      end

      context "when the the app does not have the proper scope" do
        before do
          @app4 = App.create(:name => 'App4', :redirect_uri => "http://localhost/")
          @app4.oauth_scopes << OauthScope.find_by_scope_name("notifications")
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

    describe "GET /api/tasks/:id.json" do
      before {@task = Task.create!({:name => 'New Task', :user_id => @user.id, :app_id => @app.id}, :as => :admin)}

      context "when the token is valid" do
        it "should retrieve the task" do
          get "/api/tasks/#{@task.id}", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          response.code.should == "200"
          parsed_json = JSON.parse(response.body)
          parsed_json.should_not be_nil
          parsed_json["name"].should == "New Task"
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