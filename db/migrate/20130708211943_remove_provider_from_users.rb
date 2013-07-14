class RemoveProviderFromUsers < ActiveRecord::Migration
  def up
  	User.all do |user|
  		Authenication.create(:user => user, :uid => user.uid, :provider => user.provider) if Authentication.where(:uid => user.uid, :provider => user.provider).empty?
  		user.update_attributes(:uid => SecureRandom.uuid) if user.uid.blank? or user.uid.include? 'http'
  	end
  	remove_column :users, :provider
  end

  def down
  	add_column :users, :provider, :string

  	User.all do |user|
  		user.update_attributes(:uid => user.authentications.first.uid, :provider => user.authentications.first.provider)
  	end
  end
end
