class User < ActiveRecord::Base
  validates_presence_of :email
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable, :omniauthable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me, :first_name, :last_name, :name, :provider, :uid

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
end
