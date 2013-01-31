class App < ActiveRecord::Base
  include OAuth2::Model::ClientOwner
  has_many :submitted_forms
  validates_presence_of :name, :slug #, :user
  validates_uniqueness_of :slug
  validates_presence_of :status
  validates_presence_of :redirect_uri
  validate :owner_email_matches_user
  before_validation :generate_slug, :set_user, :set_status
  after_create :create_oauth2_client
  after_update :update_oauth2_client
  belongs_to :user
  
  attr_accessor :renew_secret
  attr_accessible :description, :logo, :name, :redirect_uri, :short_description, :url, :user, :user_id, :owner_email, :status
  attr_accessible :user_id, :user, :status, :description, :logo, :name, :redirect_uri, :short_description, :url, :owner_email, :status, as: :admin
  has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "200x200>" }, :default_url => '/assets/app-icon.png'
  has_and_belongs_to_many :oauth_scopes
  
  def self.public
    where(:status => 'public')
  end

  def self.sandbox
    where(:status => 'sandbox')
  end

  def sandbox?
    self.status == 'sandbox'
  end

  def has_owner?(user)
    self.owner_email == user.email
  end


  class << self
    def default_app
      App.find_or_create_by_name("Default App"){|app| app.redirect_uri = "https://my.usa.gov", app.status = "public"}
    end

    def authentic_apps
      self.where("name != 'Default App'")
    end
  end

  def redirect_uri=(uri)
    @redirect_uri = uri
  end
  
  def redirect_uri
    @redirect_uri.blank? ? (self.oauth2_client && self.oauth2_client.redirect_uri) : @redirect_uri
  end

  def client_id
    self.oauth2_client && self.oauth2_client.client_id
  end
  
  def owner_email=(email)
    @owner_email = email
  end
  
  def owner_email
    @owner_email.blank? ? (self.user && self.user.email) : @owner_email
  end
    
  def oauth2_client
    @oauth2_client || self.oauth2_clients.first
  end
  
  def to_param
    self.slug
  end
  
  def find_scopes(scopes=nil)
    return [] if scopes.blank? || (!scopes.respond_to?(:to_a) && !scopes.respond_to?(:split))
    scopes = scopes.respond_to?(:to_a) ? scopes.to_a : scopes.split(" ")
    self.oauth_scopes.where("oauth_scopes.scope_name" => scopes)
  end
  
  private
  
  def generate_slug
    self.slug = self.name.parameterize if self.name
  end
  
  def create_oauth2_client
    @oauth2_client = OAuth2::Model::Client.new(:name => self.name, :redirect_uri => @redirect_uri)
    @oauth2_client.oauth2_client_owner_type = 'App'
    @oauth2_client.oauth2_client_owner_id = self.id
    @oauth2_client.save!
  end
  
  def update_oauth2_client
    client = self.oauth2_client
    return true if client.nil? || @redirect_uri.blank?
    
    client.redirect_uri = @redirect_uri
    client.save
  end
  
  def owner_email_matches_user
    email = self.owner_email
    return true if email.blank?
    errors.add(:owner_email, 'does not match any users') unless User.find_by_email(email)
  end
  
  def set_status
    self.status = "public" if self.status.blank?
    return true
  end
  
  def set_user
    owner = User.find_by_email(self.owner_email)
    self.user = owner if owner
  end
end
