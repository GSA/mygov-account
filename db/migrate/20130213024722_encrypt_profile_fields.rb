class EncryptProfileFields < ActiveRecord::Migration
  def up
    User.all.each do |profile|
      profile.first_name = profile.encrypted_first_name
      profile.middle_name = profile.encrypted_middle_name
      profile.last_name = profile.encrypted_last_name
      profile.name = profile.encrypted_name
      profile.address = profile.encrypted_address
      profile.address2 = profile.encrypted_address2
      profile.city = profile.encrypted_city
      profile.state = profile.encrypted_state
      profile.zip = profile.encrypted_zip
      profile.phone = profile.encrypted_phone
      profile.mobile = profile.encrypted_mobile
      profile.save
    end
  end

  def down
    User.all.each do |profile|
      [:first_name, :middle_name, :last_name, :name, :address, :address2, :city, :state, :zip, :phone, :mobile].each do |field_name|
        profile.send("encrypted_#{field_name.to_s}=", profile.send(field_name.to_s)) if profile.send("encrypted_#{field_name.to_s}")
      end
      profile.save
    end
  end
end