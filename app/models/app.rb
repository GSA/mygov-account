class App < ActiveRecord::Base
  include OAuth2::Model::ClientOwner
  has_many :submitted_forms
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug
  before_validation :generate_slug
  after_create :create_oauth2_client
  attr_accessible :description, :logo, :name, :redirect_uri, :short_description, :url
  has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "200x200>" }
  
  class << self
    
    def default_app
      App.find_or_create_by_name("Default App"){|app| app.redirect_uri = "https://my.usa.gov"}
    end

    def authentic_apps
      self.where("name != 'Default App'")
    end
  end
    
  def oauth2_client
    @oauth2_client || self.oauth2_clients.first
  end
  
  def redirect_uri=(uri)
    @redirect_uri = uri
  end
  
  def to_param
    self.slug
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
end