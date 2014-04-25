namespace :utils do

  desc "Generate API documentation"
  task :generate_api_docs do
    exec('aglio -i doc/api.md -o public/developer/api.html')
  end

end
