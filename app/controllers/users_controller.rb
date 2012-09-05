class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  before_filter :assign_user, :except => [:show]
  
  def show
    respond_to do |format|
      format.html {
        authenticate_user!
        assign_user
      }
      format.json {
        oauthorize
        unless @token.valid?
          render :json => {:status => 'Error', :message => "You do not have access to read that user's profile."}, :status => 403
        else
          @user = @token.owner
          if @user
            if params[:schema].present?
              render :json => {:status => 'OK', :user => @user.to_schema_dot_org_hash }
            else
              render :json => {:status => 'OK', :user => @user }
            end
          else
            render :json => {:status => 'Error', :message => 'Profile not found' }, :status => 404
          end
        end
      }
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your profile was sucessfully updated."
      redirect_to profile_path
    else
      flash[:error] = "Something went wrong."
      redirect_to :back
    end
  end    
end
