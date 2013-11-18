require "resque/tasks"

task "resque:setup" => :environment
Resque.logger = Logger.new(File.open(File.join(Rails.root, 'log', 'resque.log'), 'a'))