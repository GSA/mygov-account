class ActionView::Helpers::FormBuilder
	alias :orig_label :label

	# add a '*' after the field label if the field is required
	def label(method, content_or_options = nil, options = nil, &block)
		if content_or_options && content_or_options.class == Hash
			options = content_or_options
		else
			content = content_or_options
		end
		required_mark = ''
		required_mark = ' *'.html_safe if object.class.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator

		content ||= method.to_s.humanize
		content = content + required_mark

		self.orig_label(method, content, options || {}, &block)
	end
end


module ActionView
  module Helpers
    module FormHelper

      # form_fields = ['text_field','password_field','text_area','check_box','radio_button','url_field','email_field','number_field','range_field']

      def text_field(object_name, method, options = {})
        # options.merge!({'aria-required' => true}) if object_name.capitalize.constantize.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        options.merge!({'aria-required' => true}) if options[:object].class.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("text", options)
      end

      def password_field(object_name, method, options = {})
        # options.merge!({'aria-required' => true}) if object_name.capitalize.constantize.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        options.merge!({'aria-required' => true}) if options[:object].class.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("password", { :value => nil }.merge!(options))
      end

      def text_area(object_name, method, options = {})
        # options.merge!({'aria-required' => true}) if object_name.capitalize.constantize.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        options.merge!({'aria-required' => true}) if options[:object].class.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_text_area_tag(options)
      end

      def check_box(object_name, method, options = {}, checked_value = "1", unchecked_value = "0")
        # options.merge!({'aria-required' => true}) if object_name.capitalize.constantize.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        options.merge!({'aria-required' => true}) if options[:object].class.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_check_box_tag(options, checked_value, unchecked_value)
      end

      def radio_button(object_name, method, tag_value, options = {})
        options.merge!({'aria-required' => true}) if options[:object].class.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
      	# options.merge!({'aria-required' => true}) if object_name.capitalize.constantize.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_radio_button_tag(tag_value, options)
      end

      def url_field(object_name, method, options = {})
        # options.merge!({'aria-required' => true}) if object_name.capitalize.constantize.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        options.merge!({'aria-required' => true}) if options[:object].class.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("url", options)
      end

      def email_field(object_name, method, options = {})
        # options.merge!({'aria-required' => true}) if object_name.capitalize.constantize.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        options.merge!({'aria-required' => true}) if options[:object].class.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("email", options)
      end

      def number_field(object_name, method, options = {})
        # options.merge!({'aria-required' => true}) if object_name.capitalize.constantize.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        options.merge!({'aria-required' => true}) if options[:object].class.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_number_field_tag("number", options)
      end

      def range_field(object_name, method, options = {})
        # options.merge!({'aria-required' => true}) if object_name.capitalize.constantize.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        options.merge!({'aria-required' => true}) if options[:object].class.validators_on(method).map(&:class).include? ActiveModel::Validations::PresenceValidator
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_number_field_tag("range", options)
      end

    end
  end
end

