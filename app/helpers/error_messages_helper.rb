# Andrew Wayne 2010
# Error messages for Ruby on Rails 3
# This isnt available in Rails 3 and is a custom module
# made to work like the previous Rails


# Put this in your ApplicationHelper or create an error_messages_helper.rb file
# in your helpers dir

#------------- START --------------#

module ErrorMessagesHelper
# Render error messages for the given objects. 
# The :message and :header_message options are allowed.
  def error_messages_for(*objects)
    messages = objects.compact.map do |o|
      o.errors.map do |attribute, msgs|
        Array(msgs).map do |msg|
          field_name = "#{o.class.name.parameterize}_#{attribute}"
          content_tag(:li, link_to_if((attribute && (attribute != :base)), o.errors.full_message(attribute, msg).html_safe, "##{field_name}"))
        end
      end
    end.flatten
    
    return nil if messages.empty?
    
    sentence = I18n.t("errors.messages.not_saved",
                      :count => messages.count,
                      :resource => objects.map{|o| o.class.model_name.human.downcase}.to_sentence)

    html = <<-HTML
    <div id="error_explanation">
      <h2 id="errorsummary">#{sentence}</h2>
      <ol>#{messages.join("\n")}</ol>
    </div>
    HTML

    html.html_safe
  end

  module FormBuilderExtensions
    def error_messages(options = {})
      @template.error_messages_for(@object, options)
    end
  end
end

ActionView::Helpers::FormBuilder.send(:include, ErrorMessagesHelper::FormBuilderExtensions)