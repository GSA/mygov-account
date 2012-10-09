require 'open-uri'

class UsHoliday < ActiveRecord::Base
  attr_accessible :name, :observed_on, :uid
  validates_presence_of :name, :observed_on, :uid
  validates_uniqueness_of :uid

  class << self
    
    def import_from_ical
      ical_url = "http://www.google.com/calendar/ical/usa%40holiday.calendar.google.com/public/basic.ics"
      calendars = File.open(open(ical_url)) do |file|
        RiCal.parse(file)
      end
      calendars.first.events.each do |event|
        UsHoliday.create(:name => event.summary, :observed_on => event.start_time.to_date, :uid => event.uid)
      end
    end
  end
end