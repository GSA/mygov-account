class Api::FormsController < Api::ApiController
  before_filter :oauthorize_scope
  
  respond_to :json, :xml
  
  def create
    unless form_number = params[:form_number]
      render :json => {:status => "Error", :message => "Please supply a form number."}, :status => 400
    else
      form_number = params[:form_number]
      data = params[:data] || {}
      response = HTTParty.post("#{MYGOV_FORMS_HOME}/api/forms/#{form_number}/submissions", :body => {:submission => {:data => data}})
      if response.code == 201
        submitted_form = SubmittedForm.new(:form_number => form_number, :data_url => response.headers["location"])
        submitted_form.app_id = @app.id
        submitted_form.user_id = @user.id
        if submitted_form.save
          respond_with submitted_form, :location => api_form_url(submitted_form)
        else
          render :json => {:status => "Error", :message => submitted_form.errors}, :status => 400
        end
      else
        render :json => {:status => "Error", :message => "There was an error in creating your form."}, :status => 400
      end
    end
  end
  
  protected
  
  def no_scope_message
    "You do not have permission to submit forms for this user."
  end
  
  def oauthorize_scope
    validate_oauth(OauthScope.find_by_scope_name('submit_forms'))
  end
end
