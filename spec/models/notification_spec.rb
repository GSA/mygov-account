require 'spec_helper'

describe Notification do
  before do
    @valid_attributes = {
      :subject => 'Test',
      :received_at => Time.now,
      :body => 'This is a test notification',
      :identifier => 'my-app-identifier'
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
    notification = Notification.create!(@valid_attributes.merge(:user_id => @user.id, :app_id => @app.id), :as => :admin)
  end

  context "when creating a new notification" do

    before do
      @user = User.create!(email:'test@test.gov', password:'Mypassword1')
      @notification = FactoryGirl.build(:notification, user_id: @user.id)
    end

    context 'with delivery types' do
      it 'should invoke a delivery for every delivery type for the application' do
        @notification.delivery_types << FactoryGirl.build(:delivery_type, name: 'text')
        @notification.delivery_types << FactoryGirl.build(:delivery_type, name: 'dashboard')
        Resque.should_receive(:enqueue).exactly(2).times
        @notification.save
      end
    end


    context 'without any delivery types' do
      it 'should not trigger any deliveries' do
        Resque.should_not receive(:enqueue)
        @notification.save
      end
    end
  end
end
