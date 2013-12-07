class AdminRestriction
	ADMIN_EMAILS = ENV['ADMIN_EMAILS']

  def self.matches?(request)
  	user = request.env['warden'].user
    return user && ADMIN_EMAILS.include?(user.email)
  end
end