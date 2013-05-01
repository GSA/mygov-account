require 'spec_helper'

describe Task do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'Password1')
    @app = App.create!(:name => 'Test App', :redirect_uri => "http://localhost:3000/")
    @valid_attributes = {
      :name => 'Test task'
    }
  end
  
  %w{name app_id user_id}.each do |e|
    it { should validate_presence_of(e).with_message(/can't be blank/)}   
  end
  
  it { should belong_to :user }
  it { should belong_to :app }
  
  it "should create a new instance given valid attributes" do
    task = Task.new(@valid_attributes)
    task.app_id = @app.id
    task.user_id = @user.id
    task.save!
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
