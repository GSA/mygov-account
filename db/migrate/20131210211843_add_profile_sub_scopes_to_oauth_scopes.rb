class AddProfileSubScopesToOauthScopes < ActiveRecord::Migration
  def profile_sub_scopes
    [{name: 'Profile email', description: 'Read your email address', scope_name: 'profile.email', :scope_type => 'user'},
    {name: 'Profile title', description: 'Read your title (Mr./Mrs./Miss, etc.)', scope_name: 'profile.title', :scope_type => 'user'},
    {name: 'Profile first name', description: 'Read your first name', scope_name: 'profile.first_name', :scope_type => 'user'},
    {name: 'Profile middle name', description: 'Read your middle name', scope_name: 'profile.middle_name', :scope_type => 'user'},
    {name: 'Profile last name', description: 'Read your last name', scope_name: 'profile.last_name', :scope_type => 'user'},
    {name: 'Profile suffic', description: 'Read your suffix (Sr./Jr./III, etc.)', scope_name: 'profile.suffix', :scope_type => 'user'},
    {name: 'Profile address', description: 'Read your address', scope_name: 'profile.address', :scope_type => 'user'},
    {name: 'Profile address (2)', description: 'Read your address (2)', scope_name: 'profile.address2', :scope_type => 'user'},
    {name: 'Profile city', description: 'Read your city', scope_name: 'profile.city', :scope_type => 'user'},
    {name: 'Profile state', description: 'Read your state', scope_name: 'profile.state', :scope_type => 'user'},
    {name: 'Profile zip', description: 'Read your zip code', scope_name: 'profile.zip', :scope_type => 'user'},
    {name: 'Profile phone number', description: 'Read your phone number', scope_name: 'profile.phone_number', :scope_type => 'user'},
    {name: 'Profile mobile number', description: 'Read your mobile number', scope_name: 'profile.mobile_number', :scope_type => 'user'},
    {name: 'Profile gender', description: 'Read your gender', scope_name: 'profile.gender', :scope_type => 'user'},
    {name: 'Profile marital status', description: 'Read your marital status', scope_name: 'profile.marital_status', :scope_type => 'user'},
    {name: 'Profile parent', description: 'Read your parent status', scope_name: 'profile.is_parent', :scope_type => 'user'},
    {name: 'Profile student', description: 'Read your student status', scope_name: 'profile.is_student', :scope_type => 'user'},
    {name: 'Profile veteran', description: 'Read your veteran status', scope_name: 'profile.is_veteran', :scope_type => 'user'},
    {name: 'Profile retiree', description: 'Read your retiree status', scope_name: 'profile.is_retired', :scope_type => 'user'}]
  end
  

  def up
    c = 0
    profile_sub_scopes.each do |e|
      OauthScope.find_or_create_by_scope_name(e) do
        c += 1
      end
    end
    say "Added #{c} profile sub scopes."
  end

  def down
    c = 0
    profile_sub_scopes.each do |e|
      s = OauthScope.find_by_scope_name(e[:scope_name])
      if s
        s.destroy
        c += 1
      end
    end
    say "Removed #{c} profile sub scopes."
  end
end
