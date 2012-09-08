class OauthAppsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def index
    @clients = OAuth2::Model::Client.find_all_by_oauth2_client_owner_type_and_oauth2_client_owner_id("User", @user.id)
  end

  def new
    @client = OAuth2::Model::Client.new  
  end

  def create
    @client = OAuth2::Model::Client.new(params[:o_auth2_model_client])
    @client.oauth2_client_owner_type = "User"
    @client.oauth2_client_owner_id = @user.id
    if @client.save
      render :show
    else
      render :new
    end
  end

  def edit
    @client = OAuth2::Model::Client.find(params[:id])
  end

  def update
    @client = OAuth2::Model::Client.find(params[:id])
    if @client.update_attributes(params[:o_auth2_model_client])
      redirect_to oauth_app_path(@client)
    else
      flash[:error] = "Something went wrong."
      redirect_to :back
    end
  end

  def show
    @client = OAuth2::Model::Client.find(params[:id])
  end

  def destroy
    @client = OAuth2::Model::Client.find(params[:id])
    @client.destroy
    redirect_to oauth_apps_path
  end
end
