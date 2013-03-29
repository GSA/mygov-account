class User < ActiveRecord::Base
  include OAuth2::Model::ResourceOwner  
  validate :email_is_whitelisted, if: :valid_email?
  has_many :notifications, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :submitted_forms, :dependent => :destroy
  has_many :apps, :dependent => :destroy
  validates_acceptance_of :terms_of_service

  after_create :create_default_notification
  after_destroy :send_account_deleted_notification
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable, :lockable, :timeoutable, :confirmable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :terms_of_service, :as => [:default, :admin]
  attr_accessor :just_created
  
  def sandbox_apps
    self.apps.sandbox
  end
  
  class << self
    
    def find_for_open_id(access_token, signed_in_resource = nil)
      data = access_token.info
      if user = User.where(:email => data["email"]).first
        user
      else
        user = User.new(:email => data["email"], :password => Devise.friendly_token[0,20])
        user.provider = access_token.provider
        user.uid = access_token.uid
        user.just_created = true
        user.skip_confirmation!
        user.save
        user
      end
    end  
  end
  
  def confirm!
    super_response = super
    create_default_notification
    super_response
  end
    
  def create_default_notification
    notification = self.notifications.create(:subject => 'Welcome to MyUSA', :body => File.read(Rails.root.to_s + "/lib/assets/text/welcome_email_body.html").html_safe, :received_at => Time.now)  if self.confirmation_token.nil?
  end
  
  def installed_apps
    self.oauth2_authorizations.map(&:client).map(&:oauth2_client_owner)
  end
  
  private
  
  def valid_email?
    self.email? && self.email =~ Devise.email_regexp
  end
  
  def email_is_whitelisted    
    errors.add(:base, "I'm sorry, your account hasn't been approved yet.") if BetaSignup.find_by_email_and_is_approved(self.email, true).nil?
  end
    
  def send_account_deleted_notification
    UserMailer.account_deleted(self.email).deliver
  end
end
