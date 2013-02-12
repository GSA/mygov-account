require 'spec_helper'

describe Notification do
  before do
    @valid_attributes = {
      :subject => 'Test',
      :received_at => Time.now,
      :body => 'This is a test notification'
    }
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @app = App.create!(:name => 'App1'){ |app| app.redirect_uri = 'http://localhost/' }
  end
  %w{subject received_at user_id}.each do |e|
    it { should validate_presence_of(e).with_message(/can't be blank/)}
  end
   it { should belong_to :user }
   it { should belong_to :app }
  
  it "should create a new notification with valid attributes" do
    notification = Notification.create!(@valid_attributes.merge(:user_id => @user.id, :app_id => @app.id), :as => :admin)
  end
  
  context "when creating a new notification" do
    before do
      ActionMailer::Base.deliveries = []
    end
    
    context "when creating a notificaiton without an app" do
      it "should send an email to the user with the notification content" do
        notification = Notification.create!(@valid_attributes.merge(:user_id => @user.id), :as => :admin)
        email = ActionMailer::Base.deliveries.first
        email.should_not be_nil
        email.from.should == ["projectmygov@gsa.gov"]
        email.to.should == [@user.email]
        email.subject.should == "[MYUSA] #{notification.subject}"
        email.body.should =~ /Hello, #{@user.first_name}/
        email.body.should =~ /A notification for you from MyUSA/
        email.body.should =~ /#{notification.body}/
      end
    end
    
    context "when creating a notification with an app" do
      it "should send an email to the user with the notification content identifying the sending application" do
        notification = Notification.create!(@valid_attributes.merge(:user_id => @user.id, :app_id => @app.id), :as => :admin)
        email = ActionMailer::Base.deliveries.first
        email.should_not be_nil
        email.from.should == ["projectmygov@gsa.gov"]
        email.to.should == [@user.email]
        email.subject.should == "[MYUSA] [#{notification.app.name}] #{notification.subject}"
        email.body.should =~ /Hello, #{@user.first_name}/
        email.body.should =~ /The \"#{notification.app.name}\" MyUSA application has sent you the following message/
        email.body.should =~ /#{notification.body}/
      end
    end
  end
end