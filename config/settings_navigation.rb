# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |settings|
    settings.item :my_profile, 'My Profile', profile_path
    settings.item :change_password, 'Change Password', edit_user_registration_path
    settings.item :notifications_and_alerts, 'Notifications & Alerts', '/'
    settings.item :manage_applications, 'Manage Applications', '/'
    settings.item :other_networks, 'Other Networks', '/'
    settings.dom_class = 'nav nav-pills nav-stacked'
    settings.selected_class = 'active'
  end
end
