require 'spec_helper'

describe Task do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @app = App.create!(:name => 'Test App'){|app| app.redirect_uri = "http://localhost:3000/"}
    @valid_attributes = {
      :user_id => @user.id,
      :app_id => @app.id,
      :name => 'Test task'
    }
  end
  
  it { should validate_presence_of :name }
  it { should validate_presence_of :app_id }
  it { should validate_presence_of :user_id }
  it { should belong_to :user }
  it { should belong_to :app }
  
  it "should create a new instance given valid attributes" do
    Task.create!(@valid_attributes)
  end
  
  describe "#completed?" do
    it "should return true if completed_at is not nil" do
      Task.new(:completed_at => Time.now).completed?.should be_true
    end
    
    it "should return false if completed_at is nil" do
      Task.new.completed?.should be_false
    end
  end
end
