require 'spec_helper'

describe Users::RegistrationsController do

  describe "create user with invalid recaptcha" do
    context "when recaptcha fails" do
      before do
        controller.stub(:verify_recaptcha_if_needed).and_return(false)
      end
      
      it "displays all error messages even when recaptcha is invalid" do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        put :create, user: {}
        expect(assigns(:user).errors[:base]).to include("There was an error with the code below. Please re-enter!")
        expect(assigns(:user).errors[:email]).to include("can't be blank")
      end
    end
  end
end
