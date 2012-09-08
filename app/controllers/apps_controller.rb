class AppsController < ApplicationController
  before_filter :assign_app
  
  def show
  end
  
  def print_forms
  end
  
  private
  
  def assign_app
    @app = App.find_by_slug(params[:id])
  end
end
