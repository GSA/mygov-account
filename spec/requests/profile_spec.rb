require 'spec_helper'

describe "Profile" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random')
    @user.confirm!
    @profile = {:title => "", :first_name => "Joe", :middle_name => "", :last_name => "Citizen", :suffix => "", :address => "", :address2 => "", :city => "", :zip => "", :phone => "", :mobile => "", :date_of_birth => ""}
    discovery_body = File.read(Rails.root.to_s + "/spec/fixtures/google_drive_api.json")
    stub_request(:get, "https://www.googleapis.com/discovery/v1/apis/drive/v2/rest").
                  to_return(:status => 200, 
                            :body => discovery_body, 
                            :headers => {'Content-Type' => 'application/json'})
  end
  
  describe "GET /profile" do    
    context "when visiting the web site via a browser" do
      context "when logged in" do
        before do
          create_logged_in_user(@user)
        end
        
        context "when the user does not have a profile stored with a third party" do
          it "should show a user options for storing their profile with a third party" do
            visit profile_path
            page.should have_content "Your Profile"
            page.should have_content "Google Drive"
            page.should have_link "Authorize!"
          end
        end
        
        context "when the user visits a third party to authorize them to store their profile" do
          context "when the user approves the authorization" do
            before do
              stub_request(:post, "https://accounts.google.com/o/oauth2/token").to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/fixtures/google_drive_access_token.json"), :headers => {'Content-Type' => 'application/json'})
              stub_request(:post, "https://www.googleapis.com/drive/v2/files").to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/fixtures/google_drive_folder_response.json"), :headers => {'Content-Type' => 'application/json'})
              stub_request(:post, "https://www.googleapis.com/upload/drive/v2/files?alt=json&uploadType=multipart").to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/fixtures/google_drive_file.json"), :headers => {'Content-Type' => 'application/json'})
              stub_request(:get, "https://www.googleapis.com/drive/v2/files/").to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/fixtures/google_drive_file.json"), :headers => {'Content-Type' => 'application/json'})
              stub_request(:get, "http://example.com/donwloadme").to_return({:status => 200, :body => @profile.to_json, :headers => {'Content-Type' => 'application/json'}}, {:status => 200, :body => @profile.merge(:first_name => 'Joseph').to_json, :headers => {'Content-Type' => 'application/json'}})
            end
            
            it "should create and store an empty profile with the third party" do
              visit authorization_callback_path(:code => 'authorization_code')
              a_request(:post, "https://www.googleapis.com/drive/v2/files").with(:body => "{\"title\":\"Your MyUSA data\",\"description\":\"This folder contains data for your MyUSA Account.  Do not edit or delete these files.  They are managed automatically by MyUSA.\",\"mimeType\":\"application/vnd.google-apps.folder\"}").should have_been_made.once
              a_request(:post, "https://www.googleapis.com/drive/v2/files"){|request|
                request.body.include?("{\"title\":\"\",\"first_name\":\"\",\"middle_name\":\"\",\"last_name\":\"\",\"suffix\":\"\",\"address\":\"\",\"address2\":\"\",\"city\":\"\",\"state\":\"\",\"zip\":\"\",\"phone\":\"\",\"mobile\":\"\",\"date_of_birth\":\"\"}")
              }.should have_been_made.once
              page.should have_content "Your Profile"
              page.should have_content "First name: "
            end
          end
          
          context "when the user does not approve the authorization" do
            it "should not create a profile and redirect the user back to the profile page" do
              visit authorization_callback_path
              page.should have_content "Your Profile"
              page.should have_link "Authorize!"
            end
          end
        end
        
        context "when the user already has a profile stored with a third party" do
          before do
            @user.profile = @user.build_profile(:provider_name => 'GoogleDriveProvider', 
                                                :access_token => 'access token', 
                                                :refresh_token => 'refresh token', 
                                                :data => {:profile_file_id => '123456', :folder_id => '234567'})
            @user.save
            stub_request(:post, "https://accounts.google.com/o/oauth2/token").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:get, "https://www.googleapis.com/drive/v2/files/123456").to_return(:status => 200, :body => File.read(Rails.root.to_s + "/spec/fixtures/google_drive_file.json"), :headers => {'Content-Type' => 'application/json'})
            stub_request(:get, "http://example.com/donwloadme").to_return({:status => 200, :body => @profile.to_json, :headers => {'Content-Type' => 'application/json'}}, {:status => 200, :body => @profile.merge(:first_name => 'Joseph').to_json, :headers => {'Content-Type' => 'application/json'}})
            stub_request(:put, "https://www.googleapis.com/upload/drive/v2/files/123456?alt=json&newRevision=true&uploadType=multipart")          
          end
          
          it "should show the user's profile" do
            visit profile_path
            page.should have_content "Your Profile"
            page.should have_content "First name: Joe"
            page.should have_content "Last name: Citizen"
          end
          
          it "should allow the user to update their profile" do
            visit profile_path
            click_link 'Edit profile'
            fill_in 'First name', :with => 'Joseph'
            click_button 'Update profile'
            a_request(:put, "https://www.googleapis.com/upload/drive/v2/files/123456?alt=json&newRevision=true&uploadType=multipart"){|request| request.body.include?("Joseph")}.should have_been_made.once
            page.should have_content "First name: Joseph"
          end
        end
      end
    end
  end
end