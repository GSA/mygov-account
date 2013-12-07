#!/usr/bin/env ruby
require 'logger'

$LOAD_PATH.unshift ::File.expand_path(::File.dirname(Gem.loaded_specs['resque'].full_gem_path) + '/lib')

ENV['RAILS_ENV'] ||= 'production'
# include resque initializer
require ::File.expand_path(::File.dirname(__FILE__) + "/../initializers/resque")

require 'resque/server'

# Set the RESQUECONFIG env variable if you've a `resque.rb` or similar
# config file you want loaded on boot.
if ENV['RESQUECONFIG'] && ::File.exists?(::File.expand_path(ENV['RESQUECONFIG']))
  load ::File.expand_path(ENV['RESQUECONFIG'])
end

use Rack::ShowExceptions
run Resque::Server.new
