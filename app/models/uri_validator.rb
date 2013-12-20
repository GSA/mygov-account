class UriValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      uri = URI.parse(value)
      record.errors.add(attribute, (options[:message] || I18n.t('invalid_uri'))) unless uri.absolute?
    rescue URI::InvalidURIError
      record.errors.add(attribute, (options[:message] || I18n.t('invalid_uri')))
    end
  end
end
