class BetaSignup < ActiveRecord::Base
  attr_accessible :email, :ip_address, :referrer, :is_approved
  validates_presence_of :email
  validates_uniqueness_of :email
  after_create :send_beta_signup_welcome_email
  after_update :send_beta_invite
  
  private
  
  def send_beta_signup_welcome_email
    UserMailer.beta_welcome_email(self.email).deliver
  end
  
  def send_beta_invite
    UserMailer.beta_invite(self.email).deliver if is_approved_changed? && is_approved == true
  end
end
