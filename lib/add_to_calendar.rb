require "add_to_calendar/version"

require 'add_to_calendar/url_encode'

require 'cgi'
# require 'pry'


module AddToCalendar
  class Error < StandardError; end
  
  class URLs
    attr_accessor :start_datetime, :title, :timezone, :location, :url, :description, :add_url_to_description
    def initialize(start_datetime:, title:, timezone:, location: nil, url: nil, description: nil, add_url_to_description: true)
      @start_datetime = start_datetime
      @title = title
      @timezone = timezone
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
      params[:text] = title.url_encode
      params[:dates] = "#{format_date(start_datetime)}/#{format_date(start_datetime + 60*60)}" # end time is 1 hour later
      params[:ctz] = timezone
      params[:location] = location.url_encode if location
      params[:details] = description.url_encode if description
      if add_url_to_description && url
        if params[:details]
          params[:details] << "\n\n#{url}".url_encode
        else
          params[:details] = url.url_encode
        end
      end
  
      params.each do |key, value|
        calendar_url << "&#{key}=#{value}"
      end
  
      return calendar_url
    end

    def office_365_url

    end

    def yahoo_url
      # Eg. 
      calendar_url = ""
    end

    def ical_url

    end

    def apple_url
      ical_url
    end

    def outlook_url
      ical_url
    end
  
    private
      def validate_attributes
        # msg =  "- Object must be a Date, DateTime or Time object."
        # raise(ArgumentError, ":dtstart #{msg} #{hash[:dtstart].class} given") unless hash[:dtstart].kind_of? Time
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
  
      # Google Calendar format (rename method?)
      def format_date(start_datetime)
        start_datetime.strftime('%Y%m%dT%H%M%S')
      end
  end
end