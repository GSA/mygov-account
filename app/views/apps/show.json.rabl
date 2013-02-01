object @app
attributes :name, :description, :short_description, :slug, :url

node(:authorized) { |app| @user_installed_apps.include?(app) ? true : false}