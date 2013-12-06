require 'spec_helper'

describe OauthScope do
  before do
    @valid_attributes = {
      :scope_name => 'default',
      :name => 'Default Scope',
      :scope_type => 'user'
    }
  end
  
  it "should have is_parent? method" do
    OauthScope.find_by_name("Profile").is_parent?.should == true
  end
  
  it { should validate_presence_of(:scope_name).with_message(/can't be blank/) }
  it { should validate_presence_of(:name).with_message(/can't be blank/) }
  it { should validate_presence_of(:scope_type) }
  it { should ensure_inclusion_of(:scope_type).in_array(['app', 'user']) }
  
  it "should create a new oauth scope with valid attributes" do
    app = OauthScope.create!(@valid_attributes)
  end
end
