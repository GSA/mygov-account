class ChangeToEncryptedProfileFields < ActiveRecord::Migration
  class Profile < ActiveRecord::Base
    include ::Encryption
    FIELDS = [:title, :first_name, :middle_name, :last_name, :suffix, :address, :address2, :city, :state, :zip, :gender, :marital_status, :is_parent, :is_student, :is_veteran, :is_retired]
    ENCRYPTED_FIELDS = FIELDS + [:mobile, :phone]
    ENCRYPTED_FIELDS.map { |attrib| attr_encrypted attrib.to_sym, key: :key, marshal: true }
    attr_accessible :title, :first_name, :middle_name, :last_name, :suffix, :address, :address2, :city, :state, :zip, :phone_number, :mobile_number, :gender, :marital_status, :is_parent, :is_student, :is_veteran, :is_retired, :as => [:default, :admin]
    attr_accessible :user_id, :phone, :mobile, :as => :admin
  end
  
  def up
    add_encrypted_columns

    # encrypt existing profiles and update records
    ChangeToEncryptedProfileFields::Profile.all.map { |profile| add_encrypted_data(profile) }

    remove_unencrypted_columns
  end

  def down
    add_unencrypted_columns

    # decrypt existing profiles and update records
    ChangeToEncryptedProfileFields::Profile.all.map { |profile| add_unencrypted_data(profile) }

    remove_encrypted_columns
  end

private
  
  def encrypted_fields
    ChangeToEncryptedProfileFields::Profile::FIELDS + [:phone, :mobile]
  end

  def add_encrypted_columns
    # add column names with 'encrypted_' prefix
    encrypted_fields.each { |field| add_column :profiles, "#{ChangeToEncryptedProfileFields::Profile.encrypted_column_prefix}#{field}", :string }
  end

  def remove_encrypted_columns
    # remove column names without 'encrypted_' prefix
    encrypted_fields.each { |field| remove_column :profiles, "#{ChangeToEncryptedProfileFields::Profile.encrypted_column_prefix}#{field}" } 
  end

  def add_unencrypted_columns
    # restore column names without 'encrypted_' prefix
    encrypted_fields.each { |field| add_column :profiles, field, :string }
  end

  def remove_unencrypted_columns
    # remove column names without 'encrypted_' prefix
    encrypted_fields.each { |field| remove_column :profiles, field }
  end

  def add_encrypted_data(profile)
    updated_fields = []

    encrypted_fields.each do |field|
      unless profile.attributes[field.to_s].blank?
        profile.send("#{field}=".to_sym, profile.attributes[field.to_s])
        updated_fields << "encrypted_#{field} = '#{profile.send('encrypted_'+field.to_s)}'"
      end
    end
    insert "UPDATE profiles SET #{updated_fields.join(',')} WHERE id = #{profile.id}" unless updated_fields.blank?
  end

  def add_unencrypted_data(profile)
    updated_fields = []
    
    encrypted_fields.each do |field|
      unless profile.send(field).blank?
        updated_fields << "#{field} = '#{profile.send(field)}'"
      end
    end
    insert "UPDATE profiles SET #{updated_fields.join(',')} WHERE id = #{profile.id}" unless updated_fields.blank?
  end

end