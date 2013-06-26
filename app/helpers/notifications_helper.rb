module NotificationsHelper
  
  def pretty_time(time)
    case
    when Time.now - time < 1.week
      "#{distance_of_time_in_words(Time.now, time)} ago"
    when Time.now - time < 1.year
      "#{time.strftime('%B %e')}"
    else
      "#{time.strftime('%m/%d/%Y')}"
    end
  end
  
end