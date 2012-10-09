require 'spec_helper'

describe UsHistoricalEvent do
  
  it { should validate_presence_of :day }
  it { should validate_presence_of :month }
  
  it "should create a new instance given valid attributes" do
    UsHistoricalEvent.create!(:day => 1, :month => 1, :uid => '123', :summary => 'Historical Day')
    should validate_uniqueness_of :uid
    should validate_uniqueness_of :summary
  end
end
