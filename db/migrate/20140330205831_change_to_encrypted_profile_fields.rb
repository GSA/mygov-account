class ChangeToEncryptedProfileFields < ActiveRecord::Migration
  
  def up
    add_encrypted_columns

    # encrypt existing profiles and update records
    Profile.all.map { |profile| add_encrypted_data(profile) }

    remove_unencrypted_columns
  end

  def down
    add_unencrypted_columns

    # decrypt existing profiles and update records
    Profile.all.map { |profile| add_unencrypted_data(profile) }

    remove_encrypted_columns
  end

private
  
  def encrypted_fields
    Profile::FIELDS + [:phone, :mobile]
  end

  def add_encrypted_columns
    # add column names with 'encrypted_' prefix
    encrypted_fields.each { |field| add_column :profiles, "#{Profile.encrypted_column_prefix}#{field}", :string }
  end

  def remove_encrypted_columns
    # remove column names without 'encrypted_' prefix
    encrypted_fields.each { |field| remove_column :profiles, "#{Profile.encrypted_column_prefix}#{field}" } 
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
    insert "UPDATE profiles SET #{updated_fields.join(',')} WHERE id = #{profile.id}"
  end

  def add_unencrypted_data(profile)
    updated_fields = []
    
    encrypted_fields.each do |field|
      unless profile.send(field).blank?
        updated_fields << "#{field} = '#{profile.send(field)}'"
      end
    end
    insert "UPDATE profiles SET #{updated_fields.join(',')} WHERE id = #{profile.id}"
  end

end