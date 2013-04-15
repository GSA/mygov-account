class ProfileProvider
  
  def initialize(user_profile = nil)
    @user_profile = user_profile
  end
  
  # create a getter for each of the profile fields.
  Profile::PROFILE_ATTRIBUTES.each do |field_name|
    define_method(field_name.to_s) { profile[field_name.to_s] }
  end
  
  protected
  
  # default profile is empty; implement this in your subclass
  def profile
    {}
  end
  
  # default, empty profile for profile fields
  def default_profile
    Hash[Profile::PROFILE_ATTRIBUTES.map{|field_name| [field_name, ""]}]
  end
end