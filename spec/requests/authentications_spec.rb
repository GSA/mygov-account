
require 'spec_helper'

describe "Authentications" do
  before do
    @user = create_confirmed_user_with_profile
    login(@user)
  end
  
  describe "adding a new authentication" do
    context "when the user does not have a google authentication" do
      before { @user.authentications.each {|auth| auth.destroy} }

      it 'allows the user to connect to google' do
        visit root_path
        click_link 'Account'
        click_link 'Authentication providers'
        click_link 'Add an authentication provider to your account'
        click_link 'Google'
        page.should have_content "Successfully authenticated from Google account"
        current_path.should eq authentications_path
        # Make sure user can log back in with openid
        click_link 'Sign out'
        visit sign_in_path
        click_link 'Sign in with Google'
        current_path.should eq dashboard_path
      end
    end
    
    context "when another user has a google authentication with the same account" do
      before do
        @user.authentications.create(:provider => "google", :uid => '12345')
        logout
        @user2 = create_confirmed_user_with_profile(email: 'jane@citizen.org')
        @user2.authentications.each {|auth| auth.destroy}
        login(@user2)
      end

      it 'displays an error message when adding google authentication from another account' do
        visit root_path
        click_link 'Account'
        click_link 'Authentication providers'
        click_link 'Add an authentication provider to your account'
        click_link 'Google'
        page.should have_content "This external account is already linked to another MyUSA account"
        current_path.should eq authentications_path        
      end
    end
  end
  
  describe "deleting an authentication" do
    context "when the user has an authentication" do
      before do
        @user.authentications.create(:provider => "google", :uid => 'joe.citizen@gmail.com')
      end
      
      it 'allows the user to delete their authentication which disables login with that provider' do
        visit root_path
        click_link 'Account'
        click_link 'Authentication providers'
        page.should have_content 'Google'
        click_link 'Delete'
        current_path.should eq authentications_path
        page.should_not have_content 'Google'
        click_link 'Sign out'
        visit sign_in_path
        click_link 'Sign in with Google'
        current_path.should eq sign_in_path
        expect(page).to have_content "I'm sorry, your account hasn't been approved yet."
      end
    end
  end

  describe "attempting sign up with Google" do
    context "when the user does not have a google authentication" do      
      before do
        oauth_query =  {
          "error_return_to" => sign_in_url,
          "openid.ns"=> "http://specs.openid.net/auth/2.0",
          "openid.mode"=>"id_res",
          "openid.op_endpoint"=>"https://www.google.com/accounts/o8/ud",
          "openid.response_nonce"=>"2014-03-18T15:23:59Zpg4lojledCW-iQ",
          "openid.return_to"=>"http://localhost:3000/auth/google/callback?error_return_to=http://localhost:3000/sign_in&_method=post",
          "openid.assoc_handle"=>"1.12345",
          "openid.signed"=>"op_endpoint,claimed_id,identity,return_to,response_nonce,assoc_handle,ns.ext1,ns.ext2,ext1.mode,ext1.type.ext0,ext1.value.ext0,ext2.auth_time,ext2.auth_policies",
          "openid.sig"=>"12345=",
          "openid.identity"=>"12345",
          "openid.claimed_id"=>"12345",
          "openid.ns.ext1"=>"http://openid.net/srv/ax/1.0",
          "openid.ext1.mode"=>"fetch_response",
          "openid.ext1.type.ext0"=>"http://axschema.org/contact/email&openid.ext1.value.ext0=joe.citizen@gmail.com",
          "openid.ns.ext2"=>"http://specs.openid.net/extensions/pape/1.0",
          "openid.ext2.auth_time"=>"2014-03-18T15:23:58Z",
          "openid.ext2.auth_policies"=>"http://schemas.openid.net/pape/policies/2007/06/none",
          "_method" => "post"
        }.to_a.map{|x| "#{x[0]}=#{x[1]}"}.join("&")
        @oauth_url = "/auth/google/callback?#{oauth_query}"
        create_approved_beta_signup('joe.citizen@gmail.com')
        logout

      end

      it "It should require user to agree to TOS before creating user account" do
        visit sign_up_path
        #click_link 'Sign up with Google'
        visit @oauth_url
        page.should_not have_content "Password"
        page.should have_content "Terms of service must be accepted"
        check('user_terms_of_service')

        click_button 'Sign up'
        page.should have_content "Sign out"
        click_link 'Sign out'
        visit sign_in_path
        click_link 'Sign in with Google'
        page.should_not have_content "There is another MyUSA account with that email"
        page.should have_content "Sign out"
      end

      it "should display a captcha after trying to signup with openid immediately after a previous signup" do
        create_approved_beta_signup('any@email.com')
        visit sign_up_path
        page.should_not have_css "input[name=recaptcha_response_field]"
        fill_in 'Password', :with => 'Password1'
        fill_in 'Email', :with => 'any@email.com'
        fill_in 'First name', :with => 'Joe'
        fill_in 'Last name', :with => 'Citizen'
        check 'I agree to the MyUSA Terms of service and Privacy policy'
        click_button 'Sign up'
        page.should have_content 'Thank you for signing up'
        visit @oauth_url
        page.should have_css "input[name=recaptcha_response_field]"
      end

      it "It should still create an account from openid provider return even if user doesn't agree tos first time around, but does second." do
        visit sign_up_path
        visit @oauth_url

        # Click sign up before checking TOS
        click_button 'Sign up'
        page.should have_content "Terms of service must be accepted"
        page.should have_xpath("//label[@for='user_terms_of_service']//div[@class='field_with_errors']//a[@href='/terms-of-service']")
        page.should_not have_content "Password"
        # User is returned to sign up page
        check('user_terms_of_service')

        click_button 'Sign up'
        expect(page).to have_content "Sign out"
      end
    end
  end

  describe "attempting to log in from Google" do
    context "when the user does not have a google authentication but has an account with the same email" do
      before do
        create_confirmed_user_with_profile(email: 'joe.citizen@gmail.com')
        logout
      end
      
      it "provides a proper message explaining that the corresponding account doesn't allow Google authentication" do
        visit sign_in_path
        click_link 'Sign in with Google'
        current_path.should eq sign_in_path
        expect(page).to have_content "There is another MyUSA account with that email. Please sign in with the service you used to create the account. You can also reset your password."
        expect(page).to have_link("reset your password", href: new_user_password_path)
      end
    end
  end
end

def stub_env_for_omniauth
  # This a Devise specific thing for functional tests. See https://github.com/plataformatec/devise/issues/closed#issue/608
  request.env["devise.mapping"] = Devise.mappings[:user]
  env = { "omniauth.auth" => { "provider" => "facebook", "uid" => "1234", "extra" => { "user_hash" => { "email" => "ghost@nobody.com" } } } }
  @controller.stub!(:env).and_return(env)
end
