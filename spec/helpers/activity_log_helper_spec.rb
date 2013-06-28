require 'spec_helper'

describe ActivityLogHelper do

  describe "humanize log item" do
    before do
      create_approved_beta_signup('joe@citizen.org')
      @user = User.create!(:email => 'joe@citizen.org', :password => 'Password1')
      @user.confirm!

      @app1 = @user.apps.create(name: 'Public App 1', :short_description => 'Public Application 1', :description => 'A public app 1', redirect_uri: "http://localhost/")
      @app1.is_public = true
      @app1.save!
    end

    context "when a human-readable description is available" do
      before do
        @log1 = AppActivityLog.create!(:app => @app1, :user => @user, :controller => 'profiles', :action => 'show')
        @log2 = AppActivityLog.create!(:app => @app1, :user => @user, :controller => 'notifications', :action => 'create')
      end

      it "should replace the controller#action format with a human-readable message" do
        helper.humanize_log_item(@log1).should == "viewed your profile"
        helper.humanize_log_item(@log2).should == "pushed a notification"
      end
    end

    context "when a human-readable description is not available" do
      before do
        @log1 = AppActivityLog.create!(:app => @app1, :user => @user, :controller => 'foo', :action => 'bar')
      end

      it "should replace the controller#action format with a human-readable message" do
        helper.humanize_log_item(@log1).should == "accessed foo#bar"
      end
    end
  end
end
