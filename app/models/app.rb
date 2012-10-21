class App < ActiveRecord::Base
  include OAuth2::Model::ClientOwner
  has_many :criteria, :dependent => :destroy
  has_many :forms, :dependent => :destroy
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug
  before_validation :generate_slug
  after_create :create_oauth2_client
  
  attr_accessible :name, :action_phrase, :redirect_uri
  
  def oauth2_client
    @oauth2_client || self.oauth2_clients.first
  end
  
  def redirect_uri=(uri)
    @redirect_uri = uri
  end
  
  def find_forms_by_criteria(criteria_list)
    self.forms.reject{|form| !form.valid_for_criteria(criteria_list) }
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