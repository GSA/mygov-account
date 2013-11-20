# Locks down /resque with HTTP basic auth
# 	if/when an admin role is reinstated, kill this and update routes.rb
unless Rails.env == 'development' or Rails.env == 'test'
	resque_config_file = File.join(Rails.root,'config','resque.yml')
	raise "#{resque_config_file} is missing!" unless File.exists? resque_config_file
	resque_config = YAML.load_file(resque_config_file).symbolize_keys

	Resque::Server.use(Rack::Auth::Basic) do |user, password|
	  password == resque_config[:web_interface_password]
	end
end