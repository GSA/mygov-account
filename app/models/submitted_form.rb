class SubmittedForm < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  attr_accessible :data_url, :form_number, :user_id, :app_id
  validates_presence_of :data_url, :form_number
end
