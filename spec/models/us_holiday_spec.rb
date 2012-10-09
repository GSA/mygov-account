require 'spec_helper'

describe UsHoliday do
  it { should validate_presence_of :name }
  it { should validate_presence_of :observed_on }
  it { should validate_presence_of :uid }
  
  it "should create a new instance given valid attributes" do
    UsHoliday.create!(:name => 'Holiday Day', :observed_on => Date.current, :uid => '123')
    should validate_uniqueness_of :uid
  end
end
