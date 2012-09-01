require 'spec_helper'

describe TaskItem do
  before do
    @valid_attributes = {
      :name => 'Task item', 
      :url => 'http://something.com/taskitem'
    }
    @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @task = Task.new(:name => 'Test task')
    @task.user = @user
    @task.save!
  end
  
  it { should belong_to :task }
  it { should validate_presence_of :name }
  it { should validate_presence_of :url }
  
  it "should create a new instance given valid attributes" do
    task_item = TaskItem.new(@valid_attributes)
    task_item.task = @task
    task_item.save!
  end
end
