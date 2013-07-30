class Api::V1::ProfilesController < Api::ApiController
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
  
  EXTENDED_PROFILE = {:title => nil, 
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
    :email => nil,
    :gender => nil, 
    :marital_status => nil, 
    :is_parent => nil, 
    :is_retired => nil, 
    :is_veteran => nil, 
    :is_student => nil,
    :federal_employee => nil,
    :session_authentication_method => nil,
    :session_loa => nil
  }

  def show
    auth = request.env["omniauth.auth"]
    #pp session['user.session_attributes']
    if params[:schema].present?
      render :json => {:email => @user.email, :id => @user.uid}
    elsif !session['user.session_attributes'].nil?
      session_attribs = session['user.session_attributes']
      render :json => EXTENDED_PROFILE.merge(:session_authentication_method => session_attribs['samlAuthenticationStatementAuthMethod'],
                                             :session_loa => session_attribs['EAuth-LOA'],
                                             :federal_employee => { 'phone_number' => session_attribs['Phone'],
                                               'email' => session_attribs['Email-Address'],
                                               'agency' => session_attribs['Agency-Name'],
                                               'agency_code' => session_attribs['Agency-Code'],
                                               'user_classification' => session_attribs['User-Classification'],
                                               'user_status' => session_attribs['User-Status'],
                                               'user_groups' => session_attribs['GroupList']
                                             }
      )
    else
      render :json => EMPTY_PROFILE.merge(:email => @user.email, :id => @user.uid)
    end
  end
end
