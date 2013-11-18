# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :dashboard, 'Dashboard', dashboard_path
    primary.item :settings, 'Settings', settings_path
    primary.item :help, 'Help', help_path
    primary.item :logout, 'Logout', sign_out_path, link: { class: "btn btn-primary btn-sm" }
    primary.dom_class = 'nav navbar-nav col-md-6'
    primary.selected_class = 'active'
  end
end
