# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'webmock/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  
  config.before(:each) { GC.disable }
  config.after(:each) { GC.enable }
  
  config.before(:all) do
    DeferredGarbageCollection.start
  end

  config.after(:all) do
    DeferredGarbageCollection.reconsider
  end
  
  config.before(:each) do
    OauthScope.seed_data.each { |os| OauthScope.create os } if OauthScope.all.empty?
  end
  
  config.include IntegrationSpecHelper, :type => :request
end

Capybara.default_host = "http://citizen.org"

OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:google, {
  :info => {
    :email => 'joe@citizen.org',
    :name => 'Joe Citizen'
  },
  :uid => '12345',
})
OmniAuth.config.add_mock(:maxgov, {
  :uid => 'joe.citizen@usa.gov',
  :user => 'joe.citizen.@usa.gov',
  :credentials => {:ticket => 'ticket-test.gov'},
  :extra => {:attributes => {'Agency-Name' => 'Super Agency', "Email-Address" => 'joe.citizen@usa.gov'}}
})
OmniAuth.config.add_mock(:mygov, {
  :info => {
    :email => 'joe@citizen.org',
    :uid => '12345'
  },
  :uid => '12345',
})