unless Rails.env == 'test'
  twilio_config_file = File.join(Rails.root,'config','twilio.yml')
  raise "#{twilio_config_file} is missing!" unless File.exists? twilio_config_file
  twilio_config = YAML.load_file(twilio_config_file).symbolize_keys

  ENV['TWILIO_ACCOUNT_SID'] = twilio_config[:ACCOUNT_SID]
  ENV['TWILIO_AUTH_TOKEN'] = twilio_config[:AUTH_TOKEN]
  ENV['TWILIO_FROM_NUMBER'] = twilio_config[:FROM_NUMBER]
end

