namespace :bootstrap do
  
  desc "Create required files based on .example files - WARNING: This will overwrite existing config files."
  task :de_example do
    system 'for i in `find . -name "*.example"`;do cp -- "$i" "${i//.example/}";done'
  end

  desc "Generate new secret and add to initializer"
  task :setup_secret do
    require 'securerandom'
    path = "#{FileUtils.pwd}/config/initializers/01_mygov.rb"
    replace_text = File.read(path).gsub("PUT YOUR SECRET TOKEN HERE",SecureRandom.hex(64))
    File.open(path,"w") { |file| file.puts replace_text }
  end

  task :load_schema => ['db:create'] do
    Rake::Task["db:schema:load"].execute
  end
  
  task :start_server do
    system 'rails s -d'
  end

  desc 'stop a daemonized server'
  task :stop_server do
    system 'kill -9 $(cat tmp/pids/server.pid)'
  end
  
  task :open_browser do
    system 'open "http://localhost:3000"'
  end

  task :all => [:de_example, :setup_secret, :load_schema, :start_server, :open_browser]

end

desc "Up and running in one line: creates files from .example files, creates secret, loads schema, starts server, and opens the browser - WARNING: This wipes the db!"
task :bootstrap => 'bootstrap:all'