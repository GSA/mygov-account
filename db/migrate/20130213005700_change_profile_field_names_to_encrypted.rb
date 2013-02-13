class ChangeProfileFieldNamesToEncrypted < ActiveRecord::Migration
  def up
    Profile::ENCRYPTED_FIELDS.each do |field|
      rename_column :profiles, field, "encrypted_#{field.to_s}".to_sym
    end
    [:state, :zip, :phone, :mobile].each do |field|
      change_column :profiles, "encrypted_#{field.to_s}".to_sym, :string
    end
  end

  def down
    Profile::ENCRYPTED_FIELDS.each{|field| rename_column :profiles, "encrypted_#{field.to_s}".to_sym, field }
  end
end
