class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  has_many :delivery_types
  validates_presence_of :subject, :received_at, :user_id, :identifier
  # TODO: validates_uniqueness_of => identifier within scope of user
  after_create :deliver_notification #TODO: Don't do this automagically

  attr_accessible :body, :received_at, :subject, :identifier, :as => [:default, :admin]
  attr_accessible :user_id, :app_id, :as => :admin

  def self.newest_first
    order('received_at DESC, id DESC')
  end

  def self.not_viewed
    where(viewed_at: nil, deleted_at: nil)
  end

  private

  def deliver_notification
    #TODO: Find out what the delivery mechanisms are for the user
    # in notification_settings and send them
    self.delivery_types.each do |type|
      #TODO: Exclude mailer
      Resque.enqueue("Notification#{type.name.capitalize}".constantize, self.id)
    end
  end

end