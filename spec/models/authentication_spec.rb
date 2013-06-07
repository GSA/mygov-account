require 'spec_helper'

describe Authentication do
  before do
    @valid_attributes = {
      :provider => 'some provider',
      :uid => 'joe@citizen.org',
      :data => {:first_name => 'Joe', :last_name => 'Citizen'}
    }
  end
  
  it { should validate_presence_of :uid }
  it { should validate_presence_of :provider }
  it { should belong_to :user }
end
