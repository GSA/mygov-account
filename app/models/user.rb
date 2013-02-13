class User < ActiveRecord::Base
  include OAuth2::Model::ResourceOwner  
  validate :email_is_whitelisted, if: :valid_email?
  has_one :profile, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :submitted_forms, :dependent => :destroy
  has_many :apps, :dependent => :destroy
  validates_acceptance_of :terms_of_service

  after_create :create_profile
  after_create :create_default_tasks
  after_create :create_default_notification
  after_destroy :send_account_deleted_notification
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable, :lockable, :timeoutable, :confirmable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :terms_of_service, :as => [:default, :admin]
  attr_accessible :first_name, :last_name, :as => [:default]
  attr_accessor :just_created
  
  PROFILE_ATTRIBUTES = [:title, :first_name, :middle_name, :last_name, :suffix, :name, :address, :address2, :city, :state, :zip, :date_of_birth, :phone, :mobile, :gender, :marital_status, :is_parent, :is_retired, :is_student, :is_veteran]

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
        user.profile = Profile.new(:first_name => data["first_name"], :last_name => data["last_name"], :name => data["name"])
        user.skip_confirmation!
        user.save
        user
      end
    end  
  end
  
  def create_default_tasks
    task1 = self.tasks.create({:name => 'Tell us a little about yourself.', :app_id => App.default_app.id}, :as => :admin)
    task1.task_items.create(:name => 'Complete your profile today so we can help tailor MyUSA to fit your needs.', :url => "/welcome?step=info")
    task2 = self.tasks.create({:name => 'Help us make this service more tailored to your needs.', :app_id => App.default_app.id}, :as => :admin)
    task2.task_items.create(:name => 'Get started!', :url => "/welcome?step=about_you")
  end
  
  def confirm!
    super_response = super
    create_default_notification
    super_response
  end
    
  def create_default_notification
    notification = self.notifications.create(:subject => 'Welcome to MyUSA', :body => File.read(Rails.root.to_s + "/lib/assets/text/welcome_email_body.html").html_safe, :received_at => Time.now)  if self.confirmation_token.nil?
  end
  
  def local_info
    location_parts = [ 'address', 'city', 'state', 'zip']
    location = location_parts.collect{|part| self.profile[part]}.compact.join(", ")
    unless location.blank?
      url = "/geowebdns/endpoints?location=#{URI.encode(location)}&format=json&fullstack=true"
      local_info = Rails.cache.fetch('democracy_map_' + url, :expires_in => 24.hours) do
        response = Net::HTTP.get_response('api.democracymap.org', url) rescue nil
        JSON.parse(response.body) rescue nil
      end
    end
    local_info
  end
  
  def installed_apps
    self.oauth2_authorizations.map(&:client).map(&:oauth2_client_owner)
  end
  
  private
  
  def create_profile
    self.profile = Profile.new(:first_name => @first_name, :last_name => @last_name) unless self.profile
  end
  
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
