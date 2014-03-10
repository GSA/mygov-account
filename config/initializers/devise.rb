PAPE_FIELDS = {
  :preferred_auth_policies => [
    "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/privatepersonalidentifier", 
    "http://www.idmanagement.gov/schema/2009/05/icam/openid-trust-level1.pdf"
  ], 
  :max_auth_age => 1800
}

Devise.setup do |config|
  require 'devise/orm/active_record'
  require 'openid/store/filesystem'
  config.reconfirmable = true
  config.mailer_sender = DEFAULT_FROM_EMAIL
  config.lock_strategy = :failed_attempts
  config.unlock_keys = [:email]
  config.unlock_strategy = :email
  config.maximum_attempts = 5
  config.password_length = 8..128
  config.reconfirmable = true
  config.email_regexp = //
  
  if ['development', 'test'].include?(Rails.env)
    config.omniauth :open_id, :store => OpenID::Store::Filesystem.new("/tmp"), :name => 'testid', :identifier => "https://test-id.org/RP/GSALevel1.aspx", :require => 'omniauth-openid', :required => ["http://axschema.org/contact/email"], :optional => []
    config.omniauth :open_id, :store => OpenID::Store::Filesystem.new("/tmp"), :name => 'ficamidp', :identifier => "https://ficamidp.icam.pgs-lab.com/OpenIdProviderMvc", :require => 'omniauth-openid', :required => ["http://axschema.org/contact/email"], :optional => []
    config.omniauth :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id', :require => 'omniauth-openid', :required => ["http://axschema.org/contact/email"], :optional => []
    config.omniauth :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'paypal', :identifier => 'https://www.paypal.com/webapps/auth/server', :require => 'omniauth-openid', :required => ["http://axschema.org/contact/email"], :optional => []
    config.omniauth :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'verisign', :identifier => 'https://pip.verisignlabs.com/user/DIRECTED_IDENTITY_USER/yadisxrds', :require => 'omniauth-openid', :require => 'omniauth-openid', :required => ["http://axschema.org/contact/email"], :optional => []
  else
    config.omniauth :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id', :require => 'omniauth-openid', :preferred_auth_policies => PAPE_FIELDS[:preferred_auth_policies], :max_auth_age => PAPE_FIELDS[:max_auth_age], :required => ["http://axschema.org/contact/email"], :optional => []
    unless ['qa'].include?(Rails.env)
      config.omniauth :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'paypal', :identifier => 'https://www.paypal.com/webapps/auth/server', :require => 'omniauth-openid', :preferred_auth_policies => PAPE_FIELDS[:preferred_auth_policies], :max_auth_age => PAPE_FIELDS[:max_auth_age], :required => ["http://axschema.org/contact/email"], :optional => []
    end
    config.omniauth :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'verisign', :identifier => 'https://pip.verisignlabs.com/user/DIRECTED_IDENTITY_USER/yadisxrds', :require => 'omniauth-openid', :require => 'omniauth-openid', :preferred_auth_policies => PAPE_FIELDS[:preferred_auth_policies], :max_auth_age => PAPE_FIELDS[:max_auth_age], :required => ["email"], :optional => []
  end
end
