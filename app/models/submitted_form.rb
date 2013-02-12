class SubmittedForm < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  validates_presence_of :data_url, :form_number
  attr_accessible :data_url, :form_number, :as => [:default, :admin]
  attr_accessible :user_id, :app_id, :as => [:admin]
end
