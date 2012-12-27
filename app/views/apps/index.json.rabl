object @apps
attributes :name, :description, :short_description, :slug, :url
node(:authorized) { |app| @current_user_apps.include?(app) ? true : false}