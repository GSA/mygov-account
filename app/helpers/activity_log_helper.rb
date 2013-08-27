module ActivityLogHelper
  
  def activity_time(time)
    Time.now - time > 1.week ? "on #{pretty_time(time)}" : pretty_time(time)
  end
  
  def humanize_log_item(item)
    map = {
      :profiles => {
        :show => "viewed your profile"
      },
      :notifications => {
        :create => "pushed a notification"
      }
    }

    begin
      return map[item.controller.to_sym][item.action.to_sym]
    rescue
      return ['accessed', [item.controller, item.action].join('#')].join(' ')
    end
  end
end
