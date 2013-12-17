class AccountController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def index
  end
end
