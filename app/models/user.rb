class User < ActiveRecord::Base
  include OAuth2::Model::ResourceOwner  
  validate :email_is_whitelisted_or_user_had_existing_account, if: :valid_email?
  has_many :notifications, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :submitted_forms, :dependent => :destroy
  has_many :apps, :dependent => :destroy
  has_many :authentications, :dependent => :destroy
  has_many :app_activity_logs, :dependent => :destroy
  validates_acceptance_of :terms_of_service
  validates_presence_of :uid
  validates_uniqueness_of :uid
  validate :validate_password_strength

  before_validation :generate_uid
  after_create :create_default_notification
  after_destroy :send_account_deleted_notification
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :lockable, :timeoutable, :confirmable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :terms_of_service, :unconfirmed_email, :as => [:default, :admin]

  WHITELISTED_DOMAINS = %w{ .gov .mil usps.com }

  def sandbox_apps
    self.apps.sandbox
  end
  
  class << self
    
    def find_for_open_id(access_token, signed_in_resource = nil)
      data = access_token.info
      authentication = Authentication.find_by_uid_and_provider(access_token.uid, access_token.provider)
      if authentication
        authentication.user
      else
        user = User.new(:email => data['email'], :password => Devise.friendly_token[0,20])
        user.skip_confirmation!
        user.authentications.new(:uid => access_token.uid, :provider => access_token.provider, :data => access_token)
        user.save
        user
      end
    end

    def email_is_whitelisted?(email)
      return WHITELISTED_DOMAINS.any? {|d| email.end_with?(d)}
    end

  end
  
  def confirm!
    if is_reconfirmation = is_reconfirmation?
      sync_beta_signup_with_changes
    end

    super_response = super

    if is_reconfirmation
      create_email_changed_notification
    else
      create_default_notification
    end

    super_response
  end

  def create_default_notification
    notification = self.notifications.create(
      :subject     => 'Welcome to MyUSA',
      :body        => File.read(Rails.root.to_s + "/lib/assets/text/welcome_email_body.html").html_safe,
      :received_at => Time.now,
    ) if self.confirmation_token.nil?
  end

  def create_email_changed_notification
    notification = self.notifications.create(
      :subject     => 'You changed your email address',
      :body        => File.read(Rails.root.to_s + "/lib/assets/text/email_changed_body.html").html_safe,
      :received_at => Time.now,
    ) if self.confirmation_token.nil?
  end

  def installed_apps
    self.oauth2_authorizations.map(&:client).map(&:oauth2_client_owner)
  end
  
  private
  
  def valid_email?
    self.email? && self.email =~ Devise.email_regexp
  end

  def email_is_whitelisted_or_user_had_existing_account
    if self.id.nil?
      unless User.email_is_whitelisted?(self.email) or BetaSignup.find_by_email_and_is_approved(self.email, true)
        errors.add(:base, "I'm sorry, your account hasn't been approved yet.")
      end
    end
  end

  def sync_beta_signup_with_changes
    if beta_signup = BetaSignup.find_by_email_and_is_approved(self.email, true)
      beta_signup.email = self.unconfirmed_email
      beta_signup.save!
    end

    return false
  end

  def is_reconfirmation?
    self.unconfirmed_email.present?
  end

  def validate_password_strength
    errors.add(:password, "must include at least one lower case letter, one upper case letter and one digit.") if password.present? and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+/)
  end
  
  def generate_uid
    self.uid = SecureRandom.uuid if self.uid.blank?
  end
    
  def send_account_deleted_notification
    UserMailer.account_deleted(self.email).deliver
  end

end
