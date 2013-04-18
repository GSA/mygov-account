class Api::ProfilesController < Api::ApiController
  before_filter :validate_oauth
  
  EMPTY_PROFILE = {:title => nil, 
    :first_name => nil, 
    :middle_name => nil, 
    :last_name => nil, 
    :suffix => nil, 
    :address => nil, 
    :address2 => nil, 
    :city => nil, 
    :state => nil, 
    :zip => nil, 
    :phone_number => nil, 
    :mobile_number => nil, 
    :date_of_birth => nil, 
    :gender => nil, 
    :marital_status => nil, 
    :is_parent => nil, 
    :is_retired => nil, 
    :is_veteran => nil, 
    :is_student => nil}
  
  def show
    if params[:schema].present?
      render :json => EMPTY_PROFILE
    else
      render :json => EMPTY_PROFILE
    end
  end
end