class Profile < ActiveRecord::Base
  STRING_PROFILE_ATTRIBUTES = [:title, :first_name, :middle_name, :last_name, :suffix, :address, :address2, :city, :state, :zip, :phone, :mobile]
  DATE_PROFILE_ATTRIBUTES = [:date_of_birth]
  PROFILE_ATTRIBUTES = STRING_PROFILE_ATTRIBUTES + DATE_PROFILE_ATTRIBUTES

  belongs_to :user
  attr_accessible :access_token, :provider_name, :refresh_token, :data, *PROFILE_ATTRIBUTES
  serialize :data
    
  STRING_PROFILE_ATTRIBUTES.each do |field_name|
    self.class_eval("def #{field_name};@#{field_name} ||= provider.#{field_name};end")
    self.class_eval("def #{field_name}=(value);@#{field_name}=value;end")
  end
  
  DATE_PROFILE_ATTRIBUTES.each do |date_field_name|
    self.class_eval("def #{date_field_name};@#{date_field_name} ||= provider.#{date_field_name}.blank? ? nil : Date.parse(provider.#{date_field_name});end")
    self.class_eval("def #{date_field_name}=(value);@#{date_field_name}=value;end")
  end
  
  def store_profile_attributes
    provider.save(profile_attributes)
  end
  
  private
  
  def provider
    @provider ||= Kernel.qualified_const_get(self.provider_name).new(self)
  end
  
  def profile_attributes
    Hash[PROFILE_ATTRIBUTES.map{|field_name| [field_name, self.send(field_name)]}]
  end
end