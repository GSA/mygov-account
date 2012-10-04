class User < ActiveRecord::Base
  include OAuth2::Model::ResourceOwner
  include OAuth2::Model::ClientOwner
  
  validates_presence_of :email
  
  has_many :messages, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable, :lockable, :timeoutable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :title, :first_name, :last_name, :suffix, :name, :provider, :uid, :middle_name, :address, :address2, :city, :state, :zip, :date_of_birth, :phone_number, :mobile_number, :gender, :marital_status, :is_approved
  attr_accessor :just_created

  PROFILE_ATTRIBUTES = [:email, :title, :first_name, :middle_name, :last_name, :suffix, :name, :address, :address2, :city, :state, :zip, :date_of_birth, :phone_number, :mobile_number, :gender, :marital_status]
  
  after_update :send_welcome_email
  
  class << self
    
    def find_for_open_id(access_token, signed_in_resource = nil)
      data = access_token.info
      if user = User.where(:email => data["email"]).first
        user
      else
        user = User.create!(data.reject{|k| !PROFILE_ATTRIBUTES.include?(k.to_sym)}.merge(:provider => access_token.provider, :uid => access_token.uid, :password => Devise.friendly_token[0,20]))
        user.just_created = true
        user
      end
    end  
  end
  
  def active_for_authentication?
    super && is_approved? 
  end
  
  def inactive_message
    is_approved? ? super : :not_approved
  end
  
  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    if !recoverable.is_approved?
      recoverable.errors[:base] << I18n.t("devise.failure.not_approved")
    elsif recoverable.persisted?
      recoverable.send_reset_password_instructions
    end
    recoverable
  end
  
  def profile_attributes
    self.attributes.reject{|k,v| !PROFILE_ATTRIBUTES.include?(k.to_sym) }
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
  
  def address_as_array
    result = []
    result << self.address unless self.address.blank?
    result << self.address2 unless self.address2.blank?
    result << "#{[self.city, self.state].join(", ")} #{self.zip}" unless self.city.blank? and self.state.blank? and self.zip.blank?
    result
  end
  
  def as_json(options = {})
    super(:except => [:updated_at, :created_at, :uid, :provider])
  end
  
  def to_schema_dot_org_hash
    {"email" => self.email, "givenName" => self.first_name, "additionalName" => self.middle_name, "familyName" => self.last_name, "homeLocation" => {"streetAddress" => [self.address, self.address2].reject{|s| s.blank? }.join(','), "addressLocality" => self.city, "addressRegion" => self.state, "postalCode" => self.zip}, "birthDate" => self.date_of_birth.to_s, "telephone" => self.phone, "gender" => self.print_gender }
  end
  
  def send_welcome_email
    UserMailer.welcome_email(self).deliver if is_approved_changed? && is_approved == true
  end
  
  private
  
  def pretty_print_phone(number)
    number.blank? ? nil : "#{number[0..2]}-#{number[3..5]}-#{number[6..-1]}"
  end
  
  def normalize_phone_number(number)
    number.gsub(/-/, '') if number
  end
end
