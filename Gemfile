source 'http://rubygems.org'
gem 'rails', '3.2.17'
gem 'mysql2'
gem 'domainatrix'
gem 'auto-session-timeout'
gem "jquery-rails", "~> 2.3.0"
gem 'json', '~> 1.8.0'
gem 'haml'
gem 'devise'
gem 'omniauth'
gem 'oauth2-provider', :require => 'oauth2/provider', :git => 'https://github.com/GSA/oauth2-provider.git', :branch => 'bearer-header'
gem 'oauth2'
gem 'bigdecimal'
gem 'will_paginate', '~> 3.0'
gem 'cancan'
gem 'google-analytics-rails'
gem 'quiet_assets'
gem 'coffee-rails', '~> 3.2.1'
gem 'maruku'
gem 'validates_email_format_of', :git => 'https://github.com/alexdunae/validates_email_format_of.git'
# ar-octopus has to proceed permanent_records, or permanent_records #destroy(:force) call will not work
gem 'ar-octopus'
gem "permanent_records", "~> 2.3.0"
gem "httparty"
gem "paperclip", "~> 3.0"
gem "rabl"
gem 'omniauth-openid', :git => 'https://github.com/GSA/omniauth-openid.git', :branch => 'pape'
gem 'recaptcha', :require => 'recaptcha/rails'
gem 'secure_headers'
gem 'metamagic'
gem 'capistrano'
gem 'rvm-capistrano'
gem 'capistrano-resque', '~> 0.1.0', :git => 'https://github.com/GSA/capistrano-resque.git'
gem 'capistrano-maintenance'
gem 'resque', :git => 'https://github.com/resque/resque.git', :branch => '1-x-stable', :require => 'resque/server'
gem 'resque_mailer'
gem 'devise-async'
gem 'auto-session-timeout-warning'
gem 'newrelic_rpm'
gem 'roboto'
gem 'awesome_print'

group :production do
  gem 'rack-openid', :git => 'https://github.com/GSA/rack-openid.git', :branch => 'pape'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '~> 0.11.1', :require => 'v8', :platform => :ruby
  gem 'libv8', '~> 3.11.8.7', :platform => :ruby
  gem 'execjs'
  gem 'uglifier', '>= 1.0.3'
  gem 'turbo-sprockets-rails3' # conditionally precompile assets at deploy
end

group :test, :development do
  gem "brakeman", :require => false
  gem 'database_cleaner'
  gem 'guard'
  gem 'guard-rspec'
  gem "parallel_tests"
  gem 'pry'
  gem 'pry-nav'
  gem 'rspec-rails'
end

group :development do
  gem 'guard-livereload'
  gem 'haml-rails'
  gem 'hpricot'
  gem "letter_opener"
  gem 'railroady'
  gem 'ruby_parser'
  gem 'thin'
end

group :test do
  gem 'capybara', '~> 1.1.4'
  gem 'launchy'
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
