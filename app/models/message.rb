class Message < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :subject, :received_at, :o_auth2_model_client_id, :user_id
  attr_accessible :body, :received_at, :subject
  
  def app
    ::OAuth2::Model::Client.find_by_id(self.o_auth2_model_client_id)
  end
end
