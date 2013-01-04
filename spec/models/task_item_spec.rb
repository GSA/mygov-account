require 'spec_helper'

describe TaskItem do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @app= App.create!(:name => 'Test App'){|app| app.redirect_uri = "http://localhost:3000/"}
    @task = Task.new(:app_id => @app.id, :name => 'Test task')
    @task.user = @user
    @task.save!
    @valid_attributes = {
      :task_id => @task_id
    }
  end
  
  it { should belong_to :task }
  
  it "should create a new instance given valid attributes" do
    TaskItem.create!(@valid_attributes)
  end
  
  describe "#completed?" do
    it "should return true if completed_at is not nil" do
      TaskItem.new(:completed_at => Time.now).completed?.should be_true
    end
    
    it "should return false if completed_at is nil" do
      TaskItem.new.completed?.should be_false
    end
  end
end