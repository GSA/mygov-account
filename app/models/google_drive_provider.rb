require 'google/api_client'

class GoogleDriveProvider < ProfileProvider

  def initialize(profile = nil)
    super(profile)
    if profile and profile.data
      @profile_file_id = profile.data[:profile_file_id]
      @folder_id = profile.data[:folder_id]
    end
    @drive = client.discovered_api('drive', 'v2')
  end
  
  def save(profile_attributes)
    if @profile_file_id.nil?
      create_default_profile(profile_attributes)
    else
      update_profile(profile_attributes)
    end
  end
  
  def client
    @client ||= (begin
      google_api_client = Google::APIClient.new(:application_name => 'MyUSA Test', :application_version => '0.1')
      google_api_client.authorization.client_id = GOOGLE_API_CLIENT_ID
      google_api_client.authorization.client_secret = GOOGLE_API_CLIENT_SECRET
      google_api_client.authorization.redirect_uri = PROFILE_REDIRECT_URI
      google_api_client.authorization.scope = ['https://www.googleapis.com/auth/drive.file', 'https://www.googleapis.com/auth/userinfo.email', 'https://www.googleapis.com/auth/userinfo.profile']
      if @user_profile
        google_api_client.authorization.access_token = @user_profile.access_token
        google_api_client.authorization.refresh_token = @user_profile.refresh_token
      end
      google_api_client
    end)
  end
  
  def authorization_url(state = '')
    client.authorization.authorization_uri(
      :state => state,
      :approval_prompt => :force,
      :access_type => :offline
    ).to_s
  end
  
  private
  
  def profile
    @profile ||= load_profile
  end
  
  def load_profile
    @profile_file_id = create_default_profile if @profile_file_id.nil?
    get_profile
  end

  def get_profile
    profile_file = client.execute!(:api_method => @drive.files.get, :parameters => {'fileId' => @profile_file_id})
    JSON.parse(client.execute(:uri => profile_file.data.downloadUrl).body)
  end
  
  def create_default_profile(attributes = nil)
    folder_id = create_file(default_folder, nil)
    profile_file_id = create_file(default_profile_file(folder_id), (attributes || default_profile).to_json, {'uploadType' => 'multipart', 'alt' => 'json'})
    @user_profile.update_attributes(:data => (@user_profile.data || {}).merge(:folder_id => folder_id, :profile_file_id => profile_file_id))
    profile_file_id
  end
  
  def update_profile(attributes)
    client.execute!(:api_method => @drive.files.update, 
                    :body_object => default_profile_file, 
                    :media => attributes.to_json, 
                    :parameters => {
                      'fileId' => @profile_file_id,
                      'newRevision' => true,
                      'uploadType' => 'multipart',
                      'alt' => 'json'})
  end
  
    
  def default_profile_file(folder_id = nil)
    file = @drive.files.insert.request_schema.new({
      'title' => 'profile.json',
      'description' => 'Your MyUSA profile data',
      'mimeType' => 'application/json'
    })
    file.parents = [{'id' => folder_id}] if folder_id
    file
  end
  
  def default_folder
    @drive.files.insert.request_schema.new({
      'title' => 'Your MyUSA data',
      'description' => 'This folder contains data for your MyUSA Account.  Do not edit or delete these files.  They are managed automatically by MyUSA.',
      'mimeType' => 'application/vnd.google-apps.folder'
    })
  end
  
  def create_file(file, content, parameters = {})
    result = client.execute!(
      :api_method => @drive.files.insert, 
      :body_object => file, 
      :media => content, 
      :parameters => parameters
    )
    result.data.id
  end
end