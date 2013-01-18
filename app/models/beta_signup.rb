class BetaSignup < ActiveRecord::Base
  attr_accessible :email, :ip_address, :referrer
  validates_presence_of :email, {:message => "blank email"}
  validates_uniqueness_of :email, {:message => "duplicate email"}
  validates_email_format_of :email, {:message => "invalid email"}
  before_create :approve_dot_gov_emails
  after_save :send_beta_invite
  
  private
  
  def send_beta_invite
    (rand(2) == 0 ? UserMailer.beta_invite_a(self.email).deliver : UserMailer.beta_invite_b(self.email).deliver) if is_approved_changed? && is_approved == true
  end
  
  def approve_dot_gov_emails    
    self.is_approved = true if self.email.end_with?(".gov")
  end
end
