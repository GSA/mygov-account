class AppsController < ApplicationController
  before_filter :assign_app
  before_filter :save_session_info, :except => [:show, :print_forms]
  
  def show
  end
  
  def info
  end
  
  def address
  end
  
  def birthdate
  end
  
  def contact_info
  end
  
  def print_forms
  end
  
  private
  
  def assign_app
    @app = App.find_by_slug(params[:id])
  end
  
  def save_session_info
    session["app"] = {} unless session["app"]
    session["app"].merge!(params[:app])
    puts session.inspect
  end
end
