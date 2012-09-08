require 'spec_helper'

describe "Apps" do
  describe "GET /apps/:slug" do
    before do
      @app = App.create!(:name => 'Change your name')
    end
    
    it "should show a page for the app" do
      visit app_path(@app)
      page.should have_content @app.name
    end
  end
end
