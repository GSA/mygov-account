require 'spec_helper'

describe Notification do
  before do
    @valid_attributes = {
      :subject => 'Test',
      :received_at => Time.now,
      :body => 'This is a test notification'
    }
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'Password1')
    @user.profile = Profile.new(:first_name => 'Joe', :last_name => 'Citizen')
    @app = App.create!(:name => 'App1', :redirect_uri => 'http://localhost/')
  end
  %w{subject received_at user_id}.each do |e|
    it { should validate_presence_of(e).with_message(/can't be blank/)}
  end
   it { should belong_to :user }
   it { should belong_to :app }
  
  it "should create a new notification with valid attributes" do
    Notification.create!(@valid_attributes.merge(:user_id => @user.id, :app_id => @app.id), :as => :admin)
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
        email.from.should == [Mail::Address.new(DEFAULT_FROM_EMAIL).address]
        email.to.should == [@user.email]
        email.subject.should == "[MYUSA] #{notification.subject}"
        email.parts.map do |part|
          expect(part.body).to include("Hello, #{@user.profile.first_name}")
          expect(part.body).to include('A notification for you from MyUSA')
          expect(part.body).to include("#{@valid_attributes[:body]}")
        end
      end
    end
    
    context "when creating a notification with an app" do
      it "should send an email to the user with the notification content identifying the sending application" do
        notification = Notification.create!(@valid_attributes.merge(:user_id => @user.id, :app_id => @app.id, :body => "<p>#{@valid_attributes[:body]}</p>"), :as => :admin)
        email = ActionMailer::Base.deliveries.first
        email.should_not be_nil
        email.from.should == [Mail::Address.new(DEFAULT_FROM_EMAIL).address]
        email.to.should == [@user.email]
        email.subject.should == "[MYUSA] [#{notification.app.name}] #{notification.subject}"
        email.parts.map do |part|
          expect(part.body).to include("Hello, #{@user.profile.first_name}")
          expect(part.body).to include("The \"#{notification.app.name}\" MyUSA application has sent you the following message")
          expect(part.body).to include("#{@valid_attributes[:body]}")
        end
        expect(email.html_part.body).to_not include('&lt;')
      end
    end
  end
end
