class AddNotifyMeToUser < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def change
  	add_column :users, :notify_me, :boolean
	User.reset_column_information
	User.update_all(notify_me: true)
  	say "Set notify_me to true for #{User.all.count} users"
  end
end
