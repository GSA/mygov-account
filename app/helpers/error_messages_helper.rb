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
    messages = objects.compact.map { |o| o.errors.full_messages }.flatten
    unless messages.empty?
      content_tag(:div, :class => "error_messages") do
        list_items = messages.map { |msg| content_tag(:li, msg) }
        content_tag(:ul, list_items.join.html_safe)
      end
    end
  end

  module FormBuilderExtensions
    def error_messages(options = {})
      @template.error_messages_for(@object, options)
    end
  end
end

ActionView::Helpers::FormBuilder.send(:include, ErrorMessagesHelper::FormBuilderExtensions)