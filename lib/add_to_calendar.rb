require "add_to_calendar/version"

# needed for url_encode method
require "erb"
include ERB::Util
require 'tzinfo'
require 'date'
require 'pry'


module AddToCalendar
  class Error < StandardError; end
  
  class URLs
    attr_accessor :start_datetime, :title, :timezone, :location, :url, :description, :add_url_to_description
    def initialize(start_datetime:, title:, timezone:, location: nil, url: nil, description: nil, add_url_to_description: true)
      @start_datetime = start_datetime
      @title = title
      @timezone = TZInfo::Timezone.get(timezone)
      @location = location
      @url = url
      @description = description
      @add_url_to_description = add_url_to_description
  
      validate_attributes
    end
  
    def google_url
      # Eg. https://www.google.com/calendar/render?action=TEMPLATE&text=Holly%27s%208th%20Birthday!&dates=20200615T180000/20200615T190000&ctz=Europe/London&details=Join%20us%20to%20celebrate%20with%20lots%20of%20games%20and%20cake!&location=Apartments,%20London&sprop=&sprop=name:
      calendar_url = "https://www.google.com/calendar/render?action=TEMPLATE"
      params = {}
      params[:text] = url_encode(title)
      params[:dates] = "#{format_date(start_datetime)}/#{format_date(start_datetime + 60*60)}" # end time is 1 hour later
      params[:ctz] = timezone.identifier
      params[:location] = url_encode(location) if location
      params[:details] = url_encode(description) if description
      if add_url_to_description && url
        if params[:details]
          params[:details] << url_encode("\n\n#{url}")
        else
          params[:details] = url_encode(url)
        end
      end
  
      params.each do |key, value|
        calendar_url << "&#{key}=#{value}"
      end
  
      return calendar_url
    end

    # def office_365_url

    # end

    def yahoo_url
      # Eg. http://calendar.yahoo.com/?v=60&view=d&type=20&title=Holly%27s%208th%20Birthday!&st=20200615T170000Z&dur=0100&desc=Join%20us%20to%20celebrate%20with%20lots%20of%20games%20and%20cake!&in_loc=7%20Apartments,%20London
      calendar_url = "http://calendar.yahoo.com/?v=60&view=d&type=20"
      params = {}
      params[:title] = url_encode(title)
      params[:st] = utc_datetime(start_datetime)
      params[:dur] = "0100" 
      params[:desc] = url_encode(description) if description
      if add_url_to_description && url
        if params[:desc]
          params[:desc] << url_encode("\n\n#{url}")
        else
          params[:desc] = url_encode(url)
        end
      end
      params[:in_loc] = url_encode(location) if location

      params.each do |key, value|
        calendar_url << "&#{key}=#{value}"
      end
  
      return calendar_url
    end

    def ical_url
      # Downloads a *.ics file provided as a data:text href
      # Eg. data:text/calendar;charset=utf8,BEGIN:VCALENDAR%0AVERSION:2.0%0ABEGIN:VEVENT%0ADTSTART=20200610T123000Z%0ADTEND=20200610T133000Z%0ASUMMARY=Holly%27s%208th%20Birthday%21%0AURL=https%3A%2F%2Fwww.example.com%2Fevent-details%0ADESCRIPTION=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21\n\nhttps%3A%2F%2Fwww.example.com%2Fevent-details%0ALOCATION=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU%0AUID=-https%3A%2F%2Fwww.example.com%2Fevent-details%0AEND:VEVENT%0AEND:VCALENDAR
      calendar_url = "data:text/calendar;charset=utf8,BEGIN:VCALENDAR%0AVERSION:2.0%0ABEGIN:VEVENT"
      params = {}
      params[:DTSTART] = utc_datetime(start_datetime)
      params[:DTEND] = utc_datetime(start_datetime + 60*60) # 1 hour later
      params[:SUMMARY] = url_encode(title)
      params[:URL] = url_encode(url) if url
      params[:DESCRIPTION] = url_encode(description) if description
      if add_url_to_description && url
        if params[:DESCRIPTION]
          params[:DESCRIPTION] << "\n\n#{url_encode(url)}"
        else
          params[:DESCRIPTION] = url_encode(url)
        end
      end
      params[:LOCATION] = url_encode(location) if location
      params[:UID] = "-#{url_encode(url)}" if url
      params[:UID] = "-#{utc_datetime(start_datetime)}-#{url_encode(title)}" unless params[:UID] # set uid based on starttime and title only if url is unavailable

      new_line = "%0A"
      params.each do |key, value|
        calendar_url << "#{new_line}#{key}=#{value}"
      end

      calendar_url << "%0AEND:VEVENT%0AEND:VCALENDAR"

      return calendar_url
    end

    def apple_url
      ical_url
    end

    def outlook_url
      ical_url
    end
  
    private
      def validate_attributes
        msg =  "- Object must be a DateTime or Time object."
        raise(ArgumentError, ":start_datetime #{msg} #{start_datetime.class} given") unless start_datetime.kind_of? Time
        # raise(ArgumentError, ":dtend #{msg} #{hash[:dtend].class} given") unless hash[:dtend].kind_of? Time
  
        raise(ArgumentError, ":title must be a string") unless self.title.kind_of? String
        raise(ArgumentError, ":title must not be blank") if self.title.strip.empty? # strip first, otherwise " ".empty? #=> false

        if location
          raise(ArgumentError, ":location must be a string") unless self.location.kind_of? String
        end

        if description
          raise(ArgumentError, ":description must be a string") unless self.description.kind_of? String
        end
      end

      def utc_datetime(datetime)
        t = timezone.local_time(
          datetime.strftime("%Y").to_i, 
          datetime.strftime("%m").to_i, 
          datetime.strftime("%d").to_i, 
          datetime.strftime("%H").to_i, 
          datetime.strftime("%M").to_i, 
          datetime.strftime("%S").to_i
        ).utc

        formatted = t.strftime('%Y%m%dT%H%M%SZ')
      end
  
      # Google Calendar format (rename method?)
      def format_date(start_datetime)
        start_datetime.strftime('%Y%m%dT%H%M%S')
      end
  end
end