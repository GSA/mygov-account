class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def show
  end
end