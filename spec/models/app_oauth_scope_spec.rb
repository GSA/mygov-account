require 'spec_helper'

describe AppOauthScope do
  it { should belong_to :app }
  it { should belong_to :oauth_scope }
end
