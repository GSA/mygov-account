class Authentication < ActiveRecord::Base
  belongs_to :user
  attr_accessible :data, :provider, :uid
  serialize :data, Hash
  validates_presence_of :provider, :uid
  validates_uniqueness_of :uid, :scope => [:provider]

  def self.auth_hash_from_uri(uri)
    openid_identity = CGI.parse(URI.parse(uri).query)["openid.identity"]
    uid = openid_identity.kind_of?(Array) ? openid_identity.first : openid_identity # openid.identity is an array
	  email = CGI.parse(URI.parse(uri).query)["openid.ext1.value.ext0"][0]
	  provider = CGI.parse(URI.parse(uri).query)["openid.return_to"].to_s.match(/(auth\/)(.+?)(\/)/)[2]
	  # If needed OmniAuth::AuthHash also extracts other information and attaches to :extra
	  OmniAuth::AuthHash.new(:uid => uid, :provider => provider, :info => {:email => email})
  end

end
