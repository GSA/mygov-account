class RemoveProviderFromUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      provider = 'google' if user.uid =~/google/
      provider = 'verisign' if user.uid =~ /verisign/
      provider = 'paypal' if user.uid =~ /paypal/
      if provider and ['google', 'paypal', 'verisign'].include?(provider) and Authentication.find_by_uid_and_provider(user.uid, provider).nil?
        user.authentications << Authentication.new(:uid => user.uid, :provider => provider)
      end
      user.uid = SecureRandom.uuid if user.uid.blank? or user.uid.include? 'http'
      user.save
    end
  	remove_column :users, :provider
  end

  def down
  	add_column :users, :provider, :string

  	User.all.each do |user|
  		user.update_attributes(:uid => user.authentications.first.uid, :provider => user.authentications.first.provider)
  	end
  end
end
