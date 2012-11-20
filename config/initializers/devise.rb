Devise.setup do |config|
  require 'devise/orm/active_record'
  require 'openid/store/filesystem'
  config.omniauth :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id', :require => 'omniauth-openid'
  config.omniauth :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'paypal', :identifier => 'https://www.paypal.com/webapps/auth/server', :require => 'omniauth-openid'
  config.omniauth :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'verisign', :require => 'omniauth-openid'
  config.reconfirmable = true
  config.mailer_sender = DEFAULT_FROM_EMAIL
end