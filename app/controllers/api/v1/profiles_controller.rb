class Api::V1::ProfilesController < Api::ApiController
  before_filter :dump_params
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
    :gender => nil, 
    :marital_status => nil, 
    :is_parent => nil, 
    :is_retired => nil, 
    :is_veteran => nil, 
    :is_student => nil}
  
  def show
    if params[:schema].present?
      render :json => {:email => @user.email, :id => @user.uid}
    else
      render :json => EMPTY_PROFILE.merge(:email => @user.email, :id => @user.uid)
    end
  end

  def dump_params
    logger.info 'PARAMZZ'
    logger.info params
    # logger.info request.headers.inspect
    logger.info request.headers['HTTP_AUTHORIZATION']
    # binding.pry
  end
end