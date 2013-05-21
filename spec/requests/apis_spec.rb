require 'spec_helper'

describe "Apis" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'Password1')
    @user.profile = Profile.new(:first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @user.confirm!
    @app = App.create(:name => 'App1', :redirect_uri => "http://localhost/")
    @app.oauth_scopes = OauthScope.all
    authorization = OAuth2::Model::Authorization.new
    authorization.scope = @app.oauth_scopes.collect{ |s| s.scope_name }.join(" ")
    authorization.client = @app.oauth2_client
    authorization.owner = @user
    access_token = authorization.generate_access_token
    client = OAuth2::Client.new(@app.oauth2_client.client_id, @app.oauth2_client.client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
    @token = OAuth2::AccessToken.new(client, access_token)
  end

  describe "GET /api/profile" do
    context "when the request has a valid token" do
      context "when the user queried exists" do
        it "should return JSON with an empty profile with only email" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "200"
          parsed_json = JSON.parse(response.body)
          parsed_json.should_not be_nil
          parsed_json["email"].should == 'joe@citizen.org'
          parsed_json.reject{|k,v| k == "email"}.each do |key, value|
            parsed_json[key].should be_nil
          end
        end
      
        context "when the schema parameter is set" do
          it "should render the response in a Schema.org hash" do
            get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
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
      @other_user = User.create!(:email => 'jane@citizen.org', :password => 'Password1')
      @other_user.profile = Profile.new(:first_name => 'Jane', :last_name => 'Citizen', :name => 'Jane Citizen')
      @app2 = App.create!(:name => 'App2', :redirect_uri => "http://localhost:3000/")
      @app2.oauth_scopes << OauthScope.all
      create_logged_in_user(@user)
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
          post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "200"
          @user.notifications.reload
          @user.notifications.size.should == 1
          @user.notifications.first.subject.should == "Project MyUSA"
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
    
    context "when the the app does not have the proper scope" do
      before do
        @app3 = App.create(:name => 'App3', :redirect_uri => "http://localhost/")
        @app3.oauth_scopes = OauthScope.all
        authorization = OAuth2::Model::Authorization.new
        authorization.scope = "submit_forms" # this is the wrong scope for notifications
        authorization.client = @app3.oauth2_client
        authorization.owner = @user
        access_token = authorization.generate_access_token
        client = OAuth2::Client.new(@app3.oauth2_client.client_id, @app3.oauth2_client.client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
        @token3 = OAuth2::AccessToken.new(client, access_token)
      end
      
      it "should return an error message" do
        post "/api/notifications", {:notification => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token3.token}"}
        response.code.should == "403"
        parsed_json = JSON.parse(response.body)
        parsed_json["status"].should == "Error"
        parsed_json["message"].should == "You do not have access to notifications for that user."
      end
    end

    context "when the user has an invalid token" do
      it "should return an error message" do
        post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer fake_token"}
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
          @task1 = Task.create!({:name => 'Task #1', :user_id => @user.id, :app_id => @app.id}, :as => :admin)
          @task2 = Task.create!({:name => 'Task #2', :user_id => @user.id, :app_id => @app.id + 1}, :as => :admin)
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
    
    context "when the the app does not have the proper scope" do
      before do
        @app4 = App.create(:name => 'App4', :redirect_uri => "http://localhost/")
        @app4.oauth_scopes = OauthScope.all
        authorization = OAuth2::Model::Authorization.new
        authorization.scope = "submit_forms"
        authorization.client = @app4.oauth2_client
        authorization.owner = @user
        access_token = authorization.generate_access_token
        client = OAuth2::Client.new(@app4.oauth2_client.client_id, @app4.oauth2_client.client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
        @token4 = OAuth2::AccessToken.new(client, access_token)
      end
      
      it "should return an error message" do
        get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token4.token}"}
        response.code.should == "403"
        parsed_json = JSON.parse(response.body)
        parsed_json["status"].should == "Error"
        parsed_json["message"].should == "You do not have access to tasks for that user."
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
          parsed_json.should_not be_nil
          parsed_json["name"].should == "New Task"
          Task.find_all_by_name_and_user_id_and_app_id('New Task', @user.id, @app.id).should_not be_nil
        end
      end
      
      context "when the required parameters are missing" do
        it "should return an error message" do
          post "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
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
      @task = Task.create!({:name => 'New Task', :user_id => @user.id, :app_id => @app.id}, :as => :admin)
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

  describe "POST /api/forms" do
    before do
      @form_number = "ss-5"
    end
    
    context "when the caller has a valid token" do
      context "when no form number is provided" do
        it "should return an error" do
          post "/api/forms", {:data => {:first_name => 'Joe', :last_name => 'Citizen'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "400"
          parsed_json = JSON.parse(response.body)
          parsed_json["status"].should == "Error"
          parsed_json["message"].should == "Please supply a form number."
        end
      end
      
      context "when everything works the way it's supposed to" do
        before do
          stub_request(:post, "http://localhost:3002/api/forms/ss-5/submissions").to_return(:status => 201, :body => '{"guid":"1234567890"}', :headers => {:location => 'http://localhost:3002/forms/ss-5/submissions/1234567890'})
        end
        
        context "when the form saves properly" do
          it "should return the Form's generated guid" do
            post "/api/forms", {:form_number => 'ss-5', :data => {:first_name => 'Joe', :last_name => 'Citizen'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
            response.code.should == "201"
            parsed_json = JSON.parse(response.body)
            parsed_json["data_url"].should == "http://localhost:3002/forms/ss-5/submissions/1234567890"
            response.headers["location"].should =~ /http:\/\/www.example.com\/api\/forms\/.*/
          end
        end
        
        context "when there is a problem saving the response" do
          before do
            SubmittedForm.any_instance.stub(:save).and_return false
          end
          
          it "should return an error" do
            post "/api/forms", {:form_number => 'ss-5', :data => {:first_name => 'Joe', :last_name => 'Citizen'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
            response.code.should == "400"
            parsed_json = JSON.parse(response.body)
            parsed_json["status"].should == "Error"
          end
        end
      end
      
      context "when there is an error in submitting the form" do
        before do
          stub_request(:post, "http://localhost:3002/api/forms/ss-5/submissions").to_return(:status => 500)
        end
        
        it "should return an error message" do
          post "/api/forms", {:form_number => 'ss-5', :data => {:first_name => 'Joe', :last_name => 'Citizen'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "400"
          parsed_json = JSON.parse(response.body)
          parsed_json["status"].should == "Error"
          parsed_json["message"].should == "There was an error in creating your form."
        end
      end      
    end
    
    context "when the the app does not have the proper scope" do
      before do
        @app5 = App.create(:name => 'App5', :redirect_uri => "http://localhost/")
        @app5.oauth_scopes = OauthScope.all
        authorization = OAuth2::Model::Authorization.new
        authorization.scope = "notifications" # this is the wrong scope for submitting forms
        authorization.client = @app5.oauth2_client
        authorization.owner = @user
        access_token = authorization.generate_access_token
        client = OAuth2::Client.new(@app5.oauth2_client.client_id, @app5.oauth2_client.client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
        @token5 = OAuth2::AccessToken.new(client, access_token)
      end
      
      it "should return an error message" do
        post "/api/forms", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token5.token}"}
        response.code.should == "403"
        parsed_json = JSON.parse(response.body)
        parsed_json["status"].should == "Error"
        parsed_json["message"].should == "You do not have access to submit forms for that user."
      end
    end
    
    context "when the request does not have a valid token" do
      it "should return an error message" do
        post "/api/forms", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        response.code.should == "403"
        parsed_json = JSON.parse(response.body)
        parsed_json["status"].should == "Error"
        parsed_json["message"].should == "You do not have permission to submit forms for this user."
      end
    end
  end
end
