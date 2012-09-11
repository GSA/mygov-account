class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :verify_authenticity_token, :only => [:google]
  
  def google
    puts session.inspect
    @user = User.find_for_open_id(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      if session["user"]
        puts session["user"]
        user_attributes = session["user"].reject{|k,v| k == "email"}
        puts user_attributes
        @user.update_attributes(user_attributes)
        app = App.find_by_slug(session["app_name"])
        task = @user.tasks.create(:app_id => app.id)
        puts session["app"]
        criteria = session["app"].collect{|k,v| k }
        puts criteria
        forms = app.find_forms_by_criteria(criteria)
        puts forms.inspect
        forms.each do |form|
          task.task_items.create(:form_id => form.id)
        end
      end
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end  
end