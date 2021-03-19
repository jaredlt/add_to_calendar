require "add_to_calendar_links/version"

# erb util needed for url_encode method
# CGI::escape uses + instead of %20 which doesn't work for ical files
require "erb"
include ERB::Util
require 'tzinfo'
require 'date'
require 'uri'
# require 'pry'

module AddToCalendarLinks
  class Error < StandardError; end
  
  class URLs
    attr_accessor :start_datetime, :end_datetime, :title, :timezone, :location, :url, :description, :add_url_to_description, :organizer, :strip_html
    def initialize(start_datetime:, end_datetime: nil, title:, timezone:, location: nil, url: nil, description: nil, add_url_to_description: true, organizer: nil, strip_html: false)
      @start_datetime = start_datetime
      @end_datetime = end_datetime
      @title = title
      @timezone = TZInfo::Timezone.get(timezone)
      @location = location
      @url = url
      @description = description
      @add_url_to_description = add_url_to_description
      @organizer = URI.parse(organizer) if organizer
      @strip_html = strip_html
      validate_attributes
    end
  
    def google_url
      # Eg. https://www.google.com/calendar/render?action=TEMPLATE&text=Holly%27s%208th%20Birthday!&dates=20200615T180000/20200615T190000&ctz=Europe/London&details=Join%20us%20to%20celebrate%20with%20lots%20of%20games%20and%20cake!&location=Apartments,%20London&sprop=&sprop=name:
      calendar_url = "https://www.google.com/calendar/render?action=TEMPLATE"
      params = {}
      params[:text] = url_encode(title)
      if end_datetime
        params[:dates] = "#{format_date_google(start_datetime)}/#{format_date_google(end_datetime)}"
      else
        params[:dates] = "#{format_date_google(start_datetime)}/#{format_date_google(start_datetime + 60*60)}" # end time is 1 hour later
      end
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

    def yahoo_url
      # Eg. https://calendar.yahoo.com/?v=60&view=d&type=20&title=Holly%27s%208th%20Birthday!&st=20200615T170000Z&dur=0100&desc=Join%20us%20to%20celebrate%20with%20lots%20of%20games%20and%20cake!&in_loc=7%20Apartments,%20London
      calendar_url = "https://calendar.yahoo.com/?v=60&view=d&type=20"
      params = {}
      params[:title] = url_encode(title)
      params[:st] = utc_datetime(start_datetime)
      if end_datetime
        seconds = duration_seconds(start_datetime, end_datetime)
        params[:dur] = seconds_to_hours_minutes(seconds)
      else
        params[:dur] = "0100" 
      end
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

    def office365_url
      # Eg. https://outlook.live.com/calendar/0/deeplink/compose?path=/calendar/action/compose&rru=addevent&subject=Holly%27s%208th%20Birthday%21&startdt=2020-05-12T12:30:00Z&enddt=2020-05-12T16:00:00Z&body=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details&location=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU
      microsoft("office365")
    end
    
    def outlook_com_url
      # Eg. https://outlook.live.com/calendar/0/deeplink/compose?path=/calendar/action/compose&rru=addevent&subject=Holly%27s%208th%20Birthday%21&startdt=2020-05-12T12:30:00Z&enddt=2020-05-12T16:00:00Z&body=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details&location=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU
      microsoft("outlook.com")
    end

    def ical_url
      # Downloads a *.ics file provided as a data-uri
      # Eg. "data:text/calendar;charset=utf8,BEGIN:VCALENDAR%0AVERSION:2.0%0ABEGIN:VEVENT%0ADTSTART:20200512T123000Z%0ADTEND:20200512T160000Z%0ASUMMARY:Holly%27s%208th%20Birthday%21%0AURL:https%3A%2F%2Fwww.example.com%2Fevent-details%0ADESCRIPTION:Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21\\n\\nhttps%3A%2F%2Fwww.example.com%2Fevent-details%0ALOCATION:Flat%204%5C%2C%20The%20Edge%5C%2C%2038%20Smith-Dorrien%20St%5C%2C%20London%5C%2C%20N1%207GU%0AUID:-https%3A%2F%2Fwww.example.com%2Fevent-details%0AEND:VEVENT%0AEND:VCALENDAR"
      calendar_url = "data:text/calendar;charset=utf8,BEGIN:VCALENDAR%0AVERSION:2.0%0ABEGIN:VEVENT"
      params = {}
      params[:DTSTART] = utc_datetime(start_datetime)
      if end_datetime
        params[:DTEND] = utc_datetime(end_datetime)
      else
        params[:DTEND] = utc_datetime(start_datetime + 60*60) # 1 hour later
      end
      params[:SUMMARY] = url_encode_ical(title, strip_html: true) #ical doesnt support html so remove all markup. Optional for other formats
      params[:URL] = url_encode(url) if url
      params[:DESCRIPTION] = url_encode_ical(description, strip_html: true) if description
      if add_url_to_description && url
        if params[:DESCRIPTION]
          params[:DESCRIPTION] << "\\n\\n#{url_encode(url)}"
        else
          params[:DESCRIPTION] = url_encode(url)
        end
      end
      params[:LOCATION] = url_encode_ical(location) if location
      params[:UID] = "-#{url_encode(url)}" if url
      params[:UID] = "-#{utc_datetime(start_datetime)}-#{url_encode_ical(title)}" unless params[:UID] # set uid based on starttime and title only if url is unavailable
      params[:organizer] = organizer if organizer

      new_line = "%0A"
      params.each do |key, value|
        calendar_url << "#{new_line}#{key}:#{value}"
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

    def android_url
      ical_url
    end
  
    private
      def validate_attributes
        # msg =  "- Object must be a DateTime or Time object."
        msg =  "- Object must be a Time object."
        raise(ArgumentError, ":start_datetime #{msg} #{start_datetime.class} given") unless start_datetime.kind_of? Time
        if end_datetime
          raise(ArgumentError, ":end_datetime #{msg} #{end_datetime.class} given") unless end_datetime.kind_of? Time
          raise(ArgumentError, ":end_datetime must be greater than :start_datetime") unless end_datetime > start_datetime
        end
  
        raise(ArgumentError, ":title must be a string") unless self.title.kind_of? String
        raise(ArgumentError, ":title must not be blank") if self.title.strip.empty? # strip first, otherwise " ".empty? #=> false

        if location
          raise(ArgumentError, ":location must be a string") unless self.location.kind_of? String
        end

        if description
          raise(ArgumentError, ":description must be a string") unless self.description.kind_of? String
        end

        if organizer
          raise(ArgumentError, ":organizer must be a string") unless self.organizer.kind_of? String
        end
      end

      def microsoft(service)
        # Eg. 
        calendar_url = case service
        when "outlook.com"
          "https://outlook.live.com/calendar/0/deeplink/compose?path=/calendar/action/compose&rru=addevent"
        when "office365"
          "https://outlook.office.com/calendar/0/deeplink/compose?path=/calendar/action/compose&rru=addevent"
        else
          raise MicrosoftServiceError, ":service must be 'outlook.com' or 'office365'. '#{service}' given"
        end

        params = {}
        params[:subject] = url_encode(title.gsub(' & ', ' and '))
        params[:startdt] = utc_datetime_microsoft(start_datetime)
        if end_datetime
          params[:enddt] = utc_datetime_microsoft(end_datetime)
        else
          params[:enddt] = utc_datetime_microsoft(start_datetime + 60*60) # 1 hour later
        end
        params[:body] = url_encode(newlines_to_html_br(description)) if description
        if add_url_to_description && url
          if params[:body]
            params[:body] << url_encode(newlines_to_html_br("\n\n#{url}"))
          else
            params[:body] = url_encode(url)
          end
        end
        params[:location] = url_encode(location) if location
  
        params.each do |key, value|
          calendar_url << "&#{key}=#{value}"
        end
    
        return calendar_url
      end

      def utc_datetime(datetime)
        t = timezone.local_to_utc(
          Time.new(
            datetime.strftime("%Y").to_i, 
            datetime.strftime("%m").to_i, 
            datetime.strftime("%d").to_i, 
            datetime.strftime("%H").to_i, 
            datetime.strftime("%M").to_i, 
            datetime.strftime("%S").to_i
          )
        )

        return t.strftime('%Y%m%dT%H%M%SZ')
      end

      def utc_datetime_microsoft(datetime)
        t = timezone.local_to_utc(
          Time.new(
            datetime.strftime("%Y").to_i, 
            datetime.strftime("%m").to_i, 
            datetime.strftime("%d").to_i, 
            datetime.strftime("%H").to_i, 
            datetime.strftime("%M").to_i, 
            datetime.strftime("%S").to_i
          )
        )

        return t.strftime('%Y-%m-%dT%H:%M:%SZ')
      end
  
      def format_date_google(start_datetime)
        start_datetime.strftime('%Y%m%dT%H%M%S')
      end

      def duration_seconds(start_time, end_time)
        (start_time.to_i - end_time.to_i).abs
      end

      def seconds_to_hours_minutes(sec)
        "%02d%02d" % [sec / 3600, sec / 60 % 60]
      end

      def newlines_to_html_br(string)
        string.gsub(/(?:\n\r?|\r\n?)/, '<br>')
      end

      def url_encode_ical(s, strip_html: @strip_html)
        # per https://tools.ietf.org/html/rfc5545#section-3.3.11
        string = s.dup # don't modify original input

        if strip_html
          string.gsub!("<br>", "\n")
          string.gsub!("<p>", "\n")
          string.gsub!("</p>", "\n")
          string = strip_html_tags(string)
        end
        string.gsub!("\\", "\\\\\\") # \ >> \\     --yes, really: https://stackoverflow.com/questions/6209480/how-to-replace-backslash-with-double-backslash
        string.gsub!(",", "\\,")
        string.gsub!(";", "\\;")
        string.gsub!("\r\n", "\n") # so can handle all newlines the same
        string.split("\n").map { |e|
          if e.empty?
            e
          else
            url_encode(e)
          end
        }.join("\\n")
      end

      def strip_html_tags(description)
        description.dup.gsub(/<\/?[^>]*>/, "")
      end
  end
end