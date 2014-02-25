class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  has_many :delivery_types
  validates_presence_of :subject, :received_at, :user_id, :notification_type
  # TODO: validates_uniqueness_of => identifier within scope of user
  after_create :deliver_notification

  attr_accessible :body, :received_at, :subject, :notification_type, :as => [:default, :admin]
  attr_accessible :user_id, :app_id, :as => :admin

  def self.newest_first
    where(deleted_at: nil).order('received_at DESC, id DESC')
  end

  def self.not_viewed
    where(viewed_at: nil, deleted_at: nil)
  end

  def view!
    self.update_attribute :viewed_at, Time.now
  end

  private

  def deliver_notification
    self.user.notification_settings.where(notification_type: self.notification_type).each do |setting|
      #TODO: Exclude mailer
      Resque.enqueue("Notification#{setting.delivery_type.capitalize}".constantize, self.id)
    end
  end

end
