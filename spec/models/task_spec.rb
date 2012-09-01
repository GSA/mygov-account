require 'spec_helper'

describe Task do
  before do
    @valid_attributes = {
      :name => 'Task name'
    }
    @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
  end
  
  it { should validate_presence_of :name }
  it { should validate_presence_of :user_id }
  it { should belong_to :user }
  
  it "should create a new instance given valid attributes" do
    task = Task.new(@valid_attributes)
    task.user = @user
    task.save!
  end
end
