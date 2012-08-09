require 'spec_helper'

describe "HomePage" do
  describe "GET /" do
    context "when not logged in" do
      it "should prompt the user to login" do
        visit root_path
        page.should have_content("Sign in with Google")
      end
    end    
  end
end
