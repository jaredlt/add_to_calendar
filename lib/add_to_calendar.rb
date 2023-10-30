require "add_to_calendar/version"

# erb util needed for url_encode method
# CGI::escape uses + instead of %20 which doesn't work for ical files
require "erb"
include ERB::Util
require 'tzinfo'
require 'date'
# require 'pry'

module AddToCalendar
  class Error < StandardError; end
  
  class URLs
    attr_accessor :start_datetime, :end_datetime, :title, :timezone, :location, :url, :description, :add_url_to_description, :all_day, :organizer
    def initialize(start_datetime:, end_datetime: nil, title:, timezone:, location: nil, url: nil, description: nil, add_url_to_description: true, all_day: false, organizer: nil)
      @start_datetime = start_datetime
      @end_datetime = end_datetime
      @title = title
      @timezone = TZInfo::Timezone.get(timezone)
      @location = location
      @url = url
      @description = description
      @add_url_to_description = add_url_to_description
      @all_day = all_day
      @organizer = organizer
  
      validate_attributes
    end
  
    def google_url
      # Eg. https://www.google.com/calendar/render?action=TEMPLATE&text=Holly%27s%208th%20Birthday!&dates=20200615T180000/20200615T190000&ctz=Europe/London&details=Join%20us%20to%20celebrate%20with%20lots%20of%20games%20and%20cake!&location=Apartments,%20London&sprop=&sprop=name:
      calendar_url = "https://www.google.com/calendar/render?action=TEMPLATE"
      params = {}
      params[:text] = url_encode(title)
      params[:dates] = google_dates(start_datetime, end_datetime, all_day)
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
      # Eg. https://calendar.yahoo.com/?v=60&title=Holly%27s%208th%20Birthday!&st=20200615T170000Z&dur=0100&desc=Join%20us%20to%20celebrate%20with%20lots%20of%20games%20and%20cake!&in_loc=7%20Apartments,%20London
      calendar_url = "https://calendar.yahoo.com/?v=60"
      params = {}
      params[:title] = url_encode(title)
      if all_day
        params[:st] = format_date(start_datetime)
        if end_datetime
          params[:et] = format_date(end_datetime)
        else
          params[:et] = format_date(start_datetime)
        end
        params[:dur] = "allday"
      else
        params[:st] = utc_datetime(start_datetime)
        if end_datetime
          seconds = duration_seconds(start_datetime, end_datetime)
          params[:dur] = seconds_to_hours_minutes(seconds)
        else
          params[:dur] = "0100" 
        end
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
        calendar_url << "&#{yahoo_param(key)}=#{value}"
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
      calendar_url = "data:text/calendar;charset=utf8,BEGIN:VCALENDAR%0AVERSION:2.0%0APRODID:-//AddToCalendar//RubyGem//EN%0ABEGIN:VEVENT"

      params = {}
      params[:DTSTAMP] = Time.now.strftime("%Y%m%dT%H%M%SZ")
      if all_day
        one_day = 1 * 24 * 60 * 60
        params["DTSTART;VALUE=DATE"] = format_date(start_datetime)
        if end_datetime
          params["DTEND;VALUE=DATE"] = format_date(end_datetime + one_day)
        else
          params["DTEND;VALUE=DATE"] = format_date(start_datetime + one_day)
        end
      else
        params[:DTSTART] = utc_datetime(start_datetime)
        if end_datetime
          params[:DTEND] = utc_datetime(end_datetime)
        else
          params[:DTEND] = utc_datetime(start_datetime + 60*60) # 1 hour later
        end
      end
      params[:SUMMARY] = url_encode_ical(title)
      if organizer
        params[:ORGANIZER] = url_encode_ical("CN=\"#{organizer[:name]}\":mailto:#{organizer[:email]}")
      end
      params[:URL] = url_encode(url) if url
      params[:DESCRIPTION] = url_encode_ical(description) if description
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
      
      new_line = "%0A"
      params.each do |key, value|
        if key == :ORGANIZER
          calendar_url << "#{new_line}#{key};#{value}"
        else
          calendar_url << "#{new_line}#{key}:#{value}"
        end
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
          unless self.organizer.is_a?(Hash) && self.organizer[:name].is_a?(String) && self.organizer[:email].is_a?(String)
            raise(ArgumentError, ":organizer must be a Hash of format { name: \"First Last\", email: \"email@example.com\" }")
          end
        end
      end

      def microsoft(service)
        # Eg. 
        if service == "outlook.com"
          calendar_url = "https://outlook.live.com/calendar/0/deeplink/compose?path=/calendar/action/compose&rru=addevent"
        elsif service == "office365"
          calendar_url = "https://outlook.office.com/calendar/0/deeplink/compose?path=/calendar/action/compose&rru=addevent"
        else
          raise MicrosoftServiceError, ":service must be 'outlook.com' or 'office365'. '#{service}' given"
        end
        params = {}
        params[:subject] = url_encode(title.gsub(' & ', ' and '))
        if all_day
          one_day = 1 * 24 * 60 * 60
          params[:startdt] = microsoft_date(start_datetime)
          if end_datetime
            params[:enddt] = microsoft_date(end_datetime + one_day)
          else
            params[:enddt] = microsoft_date(start_datetime + one_day)
          end
          params[:allday] = "true"
        else
          params[:startdt] = utc_datetime_microsoft(start_datetime)
          if end_datetime
            params[:enddt] = utc_datetime_microsoft(end_datetime)
          else
            params[:enddt] = utc_datetime_microsoft(start_datetime + 60*60) # 1 hour later
          end
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

      def microsoft_date(date)
        date.strftime('%Y-%m-%d')
      end

      def google_dates(start_datetime, end_datetime, all_day)
        one_day = 1 * 24 * 60 * 60
        if all_day
          if end_datetime
            "#{format_date(start_datetime)}/#{format_date(end_datetime + one_day)}"
          else
            "#{format_date(start_datetime)}/#{format_date(start_datetime + one_day)}"
          end
        elsif end_datetime
          "#{format_datetime_google(start_datetime)}/#{format_datetime_google(end_datetime)}"
        else
          "#{format_datetime_google(start_datetime)}/#{format_datetime_google(start_datetime + 60*60)}" # end time is 1 hour later
        end
      end
  
      def format_datetime_google(start_datetime)
        start_datetime.strftime('%Y%m%dT%H%M%S')
      end

      def format_date(date)
        date.strftime('%Y%m%d')
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

      def url_encode_ical(s)
        # per https://tools.ietf.org/html/rfc5545#section-3.3.11
        string = s.dup # don't modify original input
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

      def yahoo_param(key)
        if key == :in_loc
          key.to_s
        else
          key.to_s.upcase
        end
      end
  end
end
