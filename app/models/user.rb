class User < ActiveRecord::Base
  include OAuth2::Model::ResourceOwner
  include OAuth2::Model::ClientOwner
  
  validates_presence_of :email
  before_validation :normalize_ssn
  before_validation :normalize_phone
  
  has_many :messages
  has_many :tasks
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable, :omniauthable, :rememberable, :trackable

  attr_accessible :email, :remember_me, :title, :first_name, :last_name, :suffix, :name, :provider, :uid, :middle_name, :address, :address2, :city, :state, :zip, :ssn, :date_of_birth, :phone, :gender, :marital_status

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
  
  def print_ssn
    self.ssn.blank? ? nil : "#{ssn[0..2]}-#{ssn[3..4]}-#{ssn[5..-1]}"
  end
  
  def print_phone
    self.phone.blank? ? nil : "#{phone[0..2]}-#{phone[3..5]}-#{phone[6..-1]}"
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
  
  def normalize_ssn
    self.ssn.gsub!(/-/, '') if self.ssn
  end
  
  def normalize_phone
    self.phone.gsub!(/-/, '') if self.phone
  end
end