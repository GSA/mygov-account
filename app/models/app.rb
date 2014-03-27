class App < ActiveRecord::Base
  include OAuth2::Model::ClientOwner
  
  belongs_to :user
  has_many :app_oauth_scopes, :dependent => :destroy
  has_many :oauth_scopes, :through => :app_oauth_scopes
  has_many :app_activity_logs
  accepts_nested_attributes_for :app_oauth_scopes

  validates_presence_of :name, :slug, :redirect_uri
  validates_inclusion_of :is_public, :in => [true, false]
  validates_uniqueness_of :slug

  before_validation :generate_slug
  after_create :create_oauth2_client
  after_update :update_oauth2_client
  
  attr_accessor :renew_secret
  attr_accessible :name, :description, :short_description, :url, :logo, :redirect_uri, :app_oauth_scopes_attributes, :custom_text, :as => [:default, :admin]
  attr_accessible :user, :user_id, :is_public, :as => :admin

  has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "200x200>" }, :default_url => '/assets/app-icon.png'
  
  class << self
    
    def public
      where(:is_public => true)
    end

    def sandbox
      where(:is_public => false)
    end

    def default_app
      App.find_or_create_by_name("Default App", :redirect_uri => 'https://my.usa.gov')
    end

    def authentic_apps
      self.public.where("name != 'Default App'")
    end
  end
  
  def sandbox?
    !self.is_public
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
end