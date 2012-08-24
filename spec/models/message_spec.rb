require 'spec_helper'

describe Message do
  before do
    @valid_attributes = {
      :subject => 'Test',
      :received_at => Time.now,
      :body => 'This is a test message'
    }
    @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @app = OAuth2::Model::Client.new(:name => 'App1', :redirect_uri => 'http://localhost/')
    @app.oauth2_client_owner_type = 'User'
    @app.oauth2_client_owner_id = @user.id
    @app.save!
  end
  
  it { should validate_presence_of :subject }
  it { should validate_presence_of :received_at }
  it { should validate_presence_of :o_auth2_model_client_id }
  it { should validate_presence_of :user_id }
  
  it "should create a new Message with valid attributes" do
    message = Message.new(@valid_attributes)
    message.user_id = @user.id
    message.o_auth2_model_client_id = @app.id
    message.save!
  end
  
  describe "#app" do
    before do
      @message = Message.new(@valid_attributes)
      @message.user_id = @user.id
      @message.o_auth2_model_client_id = @app.id
      @message.save!
    end

    it "should return the associated app" do
      @message.app.should == @app
    end
  end
end