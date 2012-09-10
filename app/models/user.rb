class User < ActiveRecord::Base
  include OAuth2::Model::ResourceOwner
  include OAuth2::Model::ClientOwner
  
  validates_presence_of :email
  before_validation :normalize_phone_numbers
  
  has_many :messages
  has_many :tasks
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable, :omniauthable, :rememberable, :trackable

  attr_accessible :email, :remember_me, :title, :first_name, :last_name, :suffix, :name, :provider, :uid, :middle_name, :address, :address2, :city, :state, :zip, :date_of_birth, :phone, :mobile, :gender, :marital_status

  class << self
    
    def find_for_open_id(access_token, signed_in_resource=nil)
      data = access_token.info
      if user = User.where(:email => data["email"]).first
        user
      else
        User.create!(data.merge(:provider => access_token.provider, :uid => access_token.uid))
      end
    end  
  end
    
  def print_phone
    pretty_print_phone(self.phone)
  end
  
  def print_mobile
    pretty_print_phone(self.mobile)
  end

  def print_gender
    self.gender.blank? ? nil : self.gender.capitalize
  end
  
  def print_marital_status
    self.marital_status.blank? ? nil : self.marital_status.titleize
  end
  
  def as_json(options = {})
    super(:except => [:updated_at, :created_at, :uid, :provider])
  end
  
  def to_schema_dot_org_hash
    {"email" => self.email, "givenName" => self.first_name, "additionalName" => self.middle_name, "familyName" => self.last_name, "homeLocation" => {"streetAddress" => [self.address, self.address2].reject{|s| s.blank? }.join(','), "addressLocality" => self.city, "addressRegion" => self.state, "postalCode" => self.zip}, "birthDate" => self.date_of_birth.to_s, "telephone" => self.print_phone, "gender" => self.print_gender }
  end
  
  private
  
  def pretty_print_phone(number)
    number.blank? ? nil : "#{number[0..2]}-#{number[3..5]}-#{number[6..-1]}"
  end
  
  def normalize_phone_numbers
    self.phone.gsub!(/-/, '') if self.phone
    self.mobile.gsub!(/-/, '') if self.mobile
  end
end