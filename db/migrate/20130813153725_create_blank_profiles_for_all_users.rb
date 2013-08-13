class CreateBlankProfilesForAllUsers < ActiveRecord::Migration
  def up
    User.all.each do |user| 
      user.profile = Profile.new unless user.profile
    end
  end

  def down
    User.all.each do |user| 
      user.profile.destroy if user.profile
    end
  end
end
