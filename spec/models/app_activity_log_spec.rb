require 'spec_helper'

describe AppActivityLog do
  it { should belong_to :app }
  it { should belong_to :user }
  
  describe ".to_s" do
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
        @log2 = AppActivityLog.create!(app: @app1, user: @user, controller: 'profiles', action: 'show')
        @log3 = AppActivityLog.create!(app: @app1, user: @user, controller: 'notifications', action: 'create')
        @log4 = AppActivityLog.create!(app: @app1, user: @user, controller: 'oauth', action: 'authorize')
        @log5 = AppActivityLog.create!(app: @app1, user: @user, controller: 'tasks', action: 'create')
        @log6 = AppActivityLog.create!(app: @app1, user: @user, controller: 'tasks', action: 'index')
        @log7 = AppActivityLog.create!(app: @app1, user: @user, controller: 'tasks', action: 'show')
        @time = @log2.created_at
      end

      it "replaces the controller#action format with a human-readable message" do
        expect(@log2.to_s).to eq "Public App 1 viewed your profile at #{@time.strftime('%H:%M %p')}"
        expect(@log3.to_s).to eq "Public App 1 pushed a notification at #{@time.strftime('%H:%M %p')}"
        expect(@log4.to_s).to eq "Public App 1 authorized your account at #{@time.strftime('%H:%M %p')}"
        expect(@log5.to_s).to eq "Public App 1 created tasks at #{@time.strftime('%H:%M %p')}"
        expect(@log6.to_s).to eq "Public App 1 viewed your task list at #{@time.strftime('%H:%M %p')}"
        expect(@log7.to_s).to eq "Public App 1 viewed a task at #{@time.strftime('%H:%M %p')}"
      end
    end

    context "when a human-readable description is not available" do
      before do
        @log = AppActivityLog.create!(:app => @app1, :user => @user, :controller => 'foo', :action => 'bar')
      end

      it "uses the controller#action format" do
        expect(@log.to_s).to eq "Public App 1 accessed foo#bar at #{@log.created_at.strftime('%H:%M %p')}"
      end
    end
  end
  
end
