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
    # Loop through types and call the deliver method on each type related that notification

    self.delivery_types.each do |type|
      Resque.enqueue("Notification#{type.name.capitalize}".constantize, self.id)
    end
  end

end

# class Notification::Dashboard
#   def deliver(notification_id)
#     puts "**** delivering for the dashboard"
#     NotificationMailer.notification_email(id).deliver
#   end
# end

# class Notification::Email
#   def deliver(notification_id)
#     puts "**** delivering for the email"
#     #current mailer stuff
#     # NotificationMailer.notification_email(self.id).deliver
#   end
# end

# class Notification::Text
#   def deliver(notification_id)
#     puts "**** delivering for the text"
#   end
# end
