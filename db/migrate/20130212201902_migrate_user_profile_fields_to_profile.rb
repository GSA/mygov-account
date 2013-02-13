class MigrateUserProfileFieldsToProfile < ActiveRecord::Migration
  def up
    User.all.each do |user|
      profile_data = {}
      User::PROFILE_ATTRIBUTES.each do |profile_field|
        profile_data[profile_field] = user.send(profile_field) unless user.send(profile_field).nil?
      end
      profile = Profile.new(profile_data)
      profile.user = user
      profile.save!
    end
  end

  def down
  end
end
