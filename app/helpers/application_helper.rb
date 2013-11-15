module ApplicationHelper

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
  
  def gender_options
    [["Male", "male"], ["Female", "female"]]
  end

  def in_or_up
    controller_name == 'sessions' ? 'in' : 'up'
  end

  def marital_status_options
    [["Single", "single"], ["Married", "married"], ["Divorced", "divorced"], ["Domestic Partnership", "domestic_partnership"], ["Widowed", "widowed"]]
  end

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

  def refresh_meta_tag_conent
    if @session_to_expire_soon
      tag('meta', :'http-equiv' => "refresh", :content => @wait_until_refresh) # If go to url and then go to login, doesn't have no_keep_alive.
    else
      tag('meta', :'http-equiv' => "refresh", :content => "#{@wait_until_refresh};#{url_for(params.merge(no_keep_alive: 1))}")
    end
  end

  def session_timeout_message
    if @session_to_expire_soon
      here = link_to(t('remain_logged_in'), url_for(params.reject{ |k,v| k == "no_keep_alive" }))
      content_tag :div, :class => "row" do
        content_tag :div, :class => "twelve columns" do
          content_tag :div, :class => "alert-box blue" do
            content_tag('div', t('session_expiration_warning', link: here.html_safe, time: pluralize(Rails.application.config.session_timeout_warning_seconds, 'second')).html_safe) + "\n" +
            link_to("&times;".html_safe, nil, class: 'close')
          end.html_safe
        end
      end
    end
  end

  def suffix_options
    ["Jr.","Sr.","II","III","IV"]
  end

  def title_options
    ["Mr.","Mrs.","Miss","Ms."]
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

  def yes_or_no(value)
    value ? "Yes" : "No"
  end

  def head_metadata(title,desc)
    meta [:charset => "utf-8"]
    meta [:property => "og:image", :content => "http://my.usa.gov/assets/apple-touch-icon-114x114-precomposed.png"]
    meta [:property => "og:description", :content => desc]
    meta [:property => "og:title", :content => title]
    meta [:property => "fb:app_id", :content => "MyUSA"]
    meta [:property => "og:type", :content => "website"]
    meta [:property => "og:url", :content => "http://my.usa.gov/"]
    meta [:name => "apple-mobile-web-app-title", :content => title]
    meta [:name => "viewport", :content => "width=device-width, user-scalable=yes"]
    meta [:name => "format-detection", :content => "telephone=yes"]
    meta [:name => "apple-mobile-web-app-capable", :content => "yes"]
    meta [:name => "HandheldFriendly", :content => "True"]
    meta ["http-equiv" => "cleartype", :content => "on"]
    meta ["http-equiv" => "X-UA-Compatible", :content => "IE=Edge,chrome=1"]
    meta ["http-equiv" => "X-XRDS-Location", :content => url_for(:action => 'xrds', :controller => controller_name, :protocol => 'https', :only_path => false, :format => :xml)]
    metamagic :title => title, :description => desc
  end
end