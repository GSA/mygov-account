source 'http://rubygems.org'

gem 'rails', '3.2.11'
gem 'mysql2'
gem 'jquery-rails'
gem 'json', '1.7.7'
gem 'haml'
gem 'devise'
gem 'capistrano'
gem 'omniauth'
gem 'oauth2-provider', :require => 'oauth2/provider', :git => 'https://github.com/GSA-OCSIT/oauth2-provider.git', :branch => 'bearer-header'
gem 'rvm-capistrano'
gem 'bigdecimal'
gem 'will_paginate', '~> 3.0'
gem 'rails_admin'
gem 'cancan'
gem 'google-analytics-rails'
gem 'quiet_assets'
gem 'coffee-rails', '~> 3.2.1'
gem "airbrake"
gem 'maruku'
gem 'validates_email_format_of', :git => 'https://github.com/alexdunae/validates_email_format_of.git'
gem "permanent_records", "~> 2.3.0"
gem "httparty"
gem "paperclip", "~> 3.0"
gem "rabl"
gem "rb-readline"
gem 'omniauth-openid', :git => 'https://github.com/GSA-OCSIT/omniauth-openid.git', :branch => 'pape'

group :production do
  gem 'rack-openid', :git => 'https://github.com/GSA-OCSIT/rack-openid.git', :branch => 'pape'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '~> 0.11.0beta5', :require => 'v8'
  gem 'libv8', '~> 3.11.8'
  gem 'execjs'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'thin'
  gem 'haml-rails'
  gem 'hpricot'
  gem 'ruby_parser'
  gem "letter_opener"
end

group :test, :development do
  gem 'rspec-rails'
  gem 'oauth2'
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'simplecov', :require => false
  gem 'webmock'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# To use debugger
# gem 'ruby-debug'
