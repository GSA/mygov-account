unless Rails.env == 'test'
  twilio_config_file = File.join(Rails.root,'config','twilio.yml')
  raise "#{twilio_config_file} is missing!" unless File.exists? twilio_config_file
  twilio_config = YAML.load_file(twilio_config_file).symbolize_keys
end

ENV['twilio_account_sid'] = twilio_config[:account_sid]
ENV['twilio_auth_token'] = twilio_config[:auth_token]
ENV['twilio_from_number'] = twilio_config[:from_number]
