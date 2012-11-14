class Users::ConfirmationsController < Devise::ConfirmationsController
  
  def after_confirmation_path_for(resource_name, resource)
    @segment == "A" ? task_path(resource.tasks.first) : dashboard_path
  end
end