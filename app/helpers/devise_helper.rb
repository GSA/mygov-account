module DeviseHelper
  def devise_error_messages!
    return "" if resource.errors.empty?

    # We allow html in the error messages we set in the en.yml file.
    messages = resource.errors.map do |attribute, msg|
      field_name = "#{resource.class.name.parameterize}_#{attribute}"
      content_tag(:li, link_to_if((attribute && (attribute != :base)), resource.errors.full_message(attribute, msg).html_safe, "##{field_name}", class: 'smoothScroll'))
    end.join("\n")
    
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)
    error_name = 'error_summary'

    html = <<-HTML
    <div id="error_explanation">
      <h2 id="#{error_name}" tabindex="-1">#{sentence}</h2>
      <ol>#{messages}</ol>
    </div>
    HTML
    
    content_for :scripts do
      javascript_tag do
        "$( document ).ready( function() { $('html,body').scrollTo('##{error_name}', 'slow'); $('##{error_name}').focus(); } );".html_safe
      end
    end

    html.html_safe
  end

  def devise_error_messages?
    resource.errors.empty? ? false : true
  end

end
