class User < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include OAuth2::Model::ResourceOwner  
  validate :email_is_whitelisted, if: :valid_email?
  validates_format_of :zip, :with => /^\d{5}?$/, :allow_blank => true, :message => "should be in the form 12345"
  validates_format_of :phone, :with => /^\d+$/, :allow_blank => true
  validates_length_of :phone, :maximum => 10
  validates_format_of :mobile, :with => /^\d+$/, :allow_blank => true
  validates_length_of :mobile, :maximum => 10
  has_many :notifications, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :submitted_forms, :dependent => :destroy
  has_many :apps #, :dependent => :destroy
  validates_acceptance_of :terms_of_service
  before_validation :update_name
  after_create :create_default_tasks
  after_create :create_default_notification
  after_destroy :send_account_deleted_notification
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable, :lockable, :timeoutable, :confirmable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :title, :first_name, :last_name, :suffix, :name, :provider, :uid, :middle_name, :address, :address2, :city, :state, :zip, :date_of_birth, :phone_number, :mobile_number, :gender, :marital_status, :is_parent, :is_veteran, :is_student, :is_retired, :terms_of_service
  attr_accessor :just_created

  PROFILE_ATTRIBUTES = [:email, :title, :first_name, :middle_name, :last_name, :suffix, :name, :address, :address2, :city, :state, :zip, :date_of_birth, :phone_number, :mobile_number, :gender, :marital_status, :is_parent, :is_veteran, :is_student, :is_retired]
  
  class << self
    
    def find_for_open_id(access_token, signed_in_resource = nil)
      data = access_token.info
      if user = User.where(:email => data["email"]).first
        user
      else
        user = User.new(data.reject{|k| !PROFILE_ATTRIBUTES.include?(k.to_sym)}.merge(:provider => access_token.provider, :uid => access_token.uid, :password => Devise.friendly_token[0,20]))
        user.just_created = true
        user.skip_confirmation!
        user.save
        user
      end
    end  
  end
  
  def phone_number=(value)
    self.phone = normalize_phone_number(value)
  end
  
  def phone_number
    pretty_print_phone(self.phone)
  end
  
  def mobile_number=(value)
    self.mobile = normalize_phone_number(value)
  end
  
  def mobile_number
    pretty_print_phone(self.mobile)
  end

  def print_gender
    self.gender.blank? ? nil : self.gender.capitalize
  end
  
  def print_marital_status
    self.marital_status.blank? ? nil : self.marital_status.titleize
  end
  
  def as_json(options = {})
    super(:only => PROFILE_ATTRIBUTES + [:id], :methods => [:phone_number, :mobile_number])
  end
  
  def to_schema_dot_org_hash
    {"email" => self.email, "givenName" => self.first_name, "additionalName" => self.middle_name, "familyName" => self.last_name, "homeLocation" => {"streetAddress" => [self.address, self.address2].reject{|s| s.blank? }.join(','), "addressLocality" => self.city, "addressRegion" => self.state, "postalCode" => self.zip}, "birthDate" => self.date_of_birth.to_s, "telephone" => self.phone, "gender" => self.print_gender }
  end
  
  def create_default_tasks
    task1 = self.tasks.create(:name => 'Tell us a little about yourself.', :app_id => App.default_app.id)
    task1.task_items.create(:name => 'Complete your profile today so we can help tailor MyGov to fit your needs.', :url => "/welcome?step=info")
    task2 = self.tasks.create(:name => 'Help us make this service more tailored to your needs.', :app_id => App.default_app.id)
    task2.task_items.create(:name => 'Get started!', :url => "/welcome?step=about_you")
  end
  
  def confirm!
    super_response = super
    create_default_notification
    super_response
  end
    
  def create_default_notification
    notification = self.notifications.create(:subject => 'Welcome to MyGov', :body => File.read(Rails.root.to_s + "/lib/assets/text/welcome_email_body.html").html_safe, :received_at => Time.now)  if self.confirmation_token.nil?
  end
  
  def local_info
    location_parts = [ 'address', 'city', 'state', 'zip']
    location = location_parts.collect{|part| self[part]}.compact.join(", ")
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
  
  def valid_email?
    self.email? && self.email =~ Devise.email_regexp
  end
  
  def email_is_whitelisted    
    errors.add(:base, "I'm sorry, your account hasn't been approved yet.") if BetaSignup.find_by_email_and_is_approved(self.email, true).nil?
  end
  
  def pretty_print_phone(number)
    number_to_phone(number)
  end
  
  def normalize_phone_number(number)
    number.gsub(/[- \(\)]/, '') if number
  end
  
  def send_account_deleted_notification
    UserMailer.account_deleted(self.email).deliver
  end
  
  def update_name
    if !self.name_changed? && (self.first_name_changed? || self.last_name_changed?)
      self.name = [self.first_name, self.last_name].compact.join(" ")
    end
  end
end