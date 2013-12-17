class BetaSignup < ActiveRecord::Base
  validates_presence_of :email
  validates_uniqueness_of :email, {:allow_blank => true}
  validates_email_format_of :email, {:allow_blank => true}
  before_create :approve_dot_gov_emails
  after_save :send_beta_invite

  attr_accessible :email, :ip_address, :referrer, :as => [:default, :admin]
  attr_accessible :is_approved, :as => :admin
  
  def approve!
    self.is_approved = true
    self.save!
  end
  
  def unapprove!
    self.is_approved = false
    self.save!
  end
  
  private

  def send_beta_invite
    UserMailer.beta_invite(self.email).deliver if is_approved_changed? && is_approved == true
  end

  def approve_dot_gov_emails
    self.is_approved = true if User.email_is_whitelisted?(self.email)
  end
end
