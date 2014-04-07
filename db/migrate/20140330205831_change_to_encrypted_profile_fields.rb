class ChangeToEncryptedProfileFields < ActiveRecord::Migration
  
  
  def up
    add_encrypted_columns

    # encrypt existing profiles
    Profile.all.each do |profile|
      encrypted_fields.each do |field|
        profile.send("#{field}=".to_sym, profile.send("#{Profile.encrypted_column_prefix}#{field}".to_sym)) if profile.send("#{Profile.encrypted_column_prefix}#{field}".to_sym)
      end
      profile.save
    end

    remove_unencrypted_columns
  end

  def down
    add_unencrypted_columns

    # TODO: need to test to make sure this restores properly.

    # decrypt existing profiles
    Profile.all.each do |profile|
      encrypted_fields.each do |field|
        profile.send("encrypted_#{field}=".to_sym, profile.send(field_name.to_s)) if profile.send("#{Profile.encrypted_column_prefix}#{field}".to_sym)
      end
      profile.save
    end

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

end