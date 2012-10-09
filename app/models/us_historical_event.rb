require 'open-uri'

class UsHistoricalEvent < ActiveRecord::Base
  attr_accessible :categories, :day, :description, :event_type, :location, :month, :summary, :uid, :url
  validates_presence_of :day, :month
  validates_uniqueness_of :summary, :uid
  
  class << self
    
    def import_events
      ical_url = "http://americanhistorycalendar.com/eventscalendar?format=ical&viewid=4"
      import(ical_url, 'event')
    end
    
    def import_birthdays
      ical_url = "http://americanhistorycalendar.com/peoplecalendar?format=ical&viewid=3"
      import(ical_url, 'birthday')
    end
    
    def import(ical_url, type)
      calendars = File.open(open(ical_url)) do |file|
        RiCal.parse(file)
      end
      calendars.first.events.each do |event|
        UsHistoricalEvent.create(:summary => event.summary, :day => event.start_time.to_date.day, :month => event.start_time.to_date.month, :uid => event.uid, :description => event.description, :location => event.location, :url => event.url, :categories => event.categories, :event_type => type)
      end
    end
  end
end
