require 'spec_helper'

describe NotificationsController do

  describe "GET #show" do
    before do
      @user = create_confirmed_user
      sign_in(@user)
      @notification = @user.notifications.last
    end
    
    it "updates the notification viewed_at timestamp" do
      expect(@notification.viewed_at?).to eq(false)
      
      get :show, id: @notification
      @notification.reload
      
      expect(@notification.viewed_at?).to eq(true)
    end

    context "with a previously viewed notification" do
      it "updates the notification viewed_at timestamp" do
        get :show, id: @notification
        @notification.reload
        original_viewed_at_time = @notification.viewed_at
        sleep(1)
        get :show, id: @notification
        @notification.reload

        expect(@notification.viewed_at).not_to eq(original_viewed_at_time)
      end
    end # end context "with a previously viewed notification"
    
  end # end GET #show
  
end