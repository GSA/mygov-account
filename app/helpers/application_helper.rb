module ApplicationHelper
  
  def session_timeout_message
    content_tag('div', t('session_expiration_warning', time: pluralize(Rails.application.config.session_timeout_warning_seconds, 'second'))) if @session_will_expire
  end
  
  def refresh_meta_tag_conent
    if @session_will_expire
      tag('meta', :'http-equiv' => "refresh", :content => @wait_until_refresh)
    else
      tag('meta', :'http-equiv' => "refresh", :content => "#{@wait_until_refresh};#{url_for(params.merge(no_keep_alive: 1))}")
    end
  end
  
  def title_options
    ["Mr.","Mrs.","Miss","Ms."]
  end
  
  def suffix_options
    ["Jr.","Sr.","II","III","IV"]
  end
  
  def us_state_options
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
  end
  
  def gender_options
    [["Male", "male"], ["Female", "female"]]
  end
  
  def marital_status_options
    [["Single", "single"], ["Married", "married"], ["Divorced", "divorced"], ["Domestic Partnership", "domestic_partnership"], ["Widowed", "widowed"]]
  end
  
  def yes_or_no(value)
    value ? "Yes" : "No"
  end
    
  def error_messages(resource)
    if resource.errors.any?
      html = ""
      errors = content_tag :div, :class => 'alert-box alert' do
        messages = resource.errors.collect do |key, msg|
          content_tag(:div, t("#{key}_error".to_sym), :class => key).html_safe
        end
        messages.join(" ").html_safe
      end
      html << errors
      html.html_safe
    else
      ""
    end
  end
end