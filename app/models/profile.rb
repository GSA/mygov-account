class Profile < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  belongs_to :user
  validates_format_of :zip, :with => /\A\d{5}?\z/, :allow_blank => true, :message => "should be in the form 12345"
  validates_format_of :phone, :with => /\A\d+\z/, :allow_blank => true
  validates_length_of :phone, :maximum => 10
  validates_format_of :mobile, :with => /\A\d+\z/, :allow_blank => true
  validates_length_of :mobile, :maximum => 10
  
  before_validation :update_name
  after_validation :set_errors
  
  ENCRYPTED_FIELDS = [:first_name, :middle_name, :last_name, :name, :address, :address2, :city, :state, :zip, :phone, :mobile]
  
  attr_accessible :title, :first_name, :middle_name, :last_name, :suffix, :name, :address, :address2, :city, :state, :zip, :phone_number, :mobile_number, :gender, :marital_status, :is_parent, :is_student, :is_veteran, :is_retired, :as => [:default, :admin]
  attr_accessible :user_id, :phone, :mobile, :as => :admin
    
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
    super(:only => [:id, :title, :suffix, :gender, :marital_status, :is_parent, :is_student, :is_veteran, :is_retired], :methods => ENCRYPTED_FIELDS + [:email])
  end
  
  def to_schema_dot_org_hash
    {"email" => self.user.email, "givenName" => self.first_name, "additionalName" => self.middle_name, "familyName" => self.last_name, "homeLocation" => {"streetAddress" => [self.address, self.address2].reject{|s| s.blank? }.join(','), "addressLocality" => self.city, "addressRegion" => self.state, "postalCode" => self.zip}, "telephone" => self.phone, "gender" => self.print_gender }
  end
  
  def email
    self.user ? self.user.email : nil
  end
  
  private
  
  def pretty_print_phone(number)
    number_to_phone(number)
  end
  
  def normalize_phone_number(number)
    number.gsub(/[- \(\)]/, '') if number
  end
  
  def update_name
    self.name = [self.first_name, self.last_name].compact.join(" ") if !self.name_changed? && (self.first_name_changed? || self.last_name_changed?)
  end
  
  def set_errors
    self.errors.add(:phone_number, self.errors.delete(:phone)) unless self.errors[:phone].blank?
    self.errors.add(:mobile_number, self.errors.delete(:mobile)) unless self.errors[:mobile].blank?
  end 
end