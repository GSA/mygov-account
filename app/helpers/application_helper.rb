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

  def custom_message
    html = ""
    client_id = session[:user_return_to]
    if client_id && (client_id.starts_with?("http:") || client_id.starts_with?("/"))
      client_id = URI.extract("http://#{client_id}").try(:first)
      client_id = URI.parse(client_id).try(:query) if client_id
      client_id = (CGI::parse(client_id) || {})['client_id'].try(:first) if client_id
    end
#    client_id = params[:client_id] unless client_id
    app_id = OAuth2::Model::Client.find_by_client_id(client_id).try(:oauth2_client_owner_id)
    app = app_id && App.find(app_id)
    return html unless app && !app.custom_text.blank?
    html << content_tag(:div) do
      app.custom_text
    end
    html.html_safe
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
    if @session_will_expire
      tag('meta', :'http-equiv' => "refresh", :content => @wait_until_refresh)
    else
      tag('meta', :'http-equiv' => "refresh", :content => "#{@wait_until_refresh};#{url_for(params.merge(no_keep_alive: 1))}")
    end
  end

  def session_timeout_message
    if @session_will_expire
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

end
