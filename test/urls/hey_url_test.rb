require "test_helper"

class HeyUrlTest < Minitest::Test
  def setup
    # We need to freeze time on each test because DTSTAMP is generated via Time.now
    Timecop.freeze(Time.now.utc)
  end

  def teardown
    Timecop.return
  end
  
  def test_without_end_datetime_ends_one_hour_after_start
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      title: event.title, 
      timezone: event.timezone
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
               "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
               "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
               "%0ASUMMARY%3A#{event.title_encoded}" + 
               "%0ADTSTAMP%3A#{event.dtstamp}" + 
               "%0ADTSTART%3A#{event.dtstart}" + 
               "%0ADTEND%3A#{event.dtstart_plus_one_hour}" + 
               event.uid + 
               "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end
  
  def test_with_end_datetime
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      end_datetime: Time.new(2024,9,6,15,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC"
    )
  
    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      end_datetime: event.end_datetime, 
      title: event.title, 
      timezone: event.timezone
    )
  
    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3A#{event.dtstart}" + 
                "%0ADTEND%3A#{event.dtend}" + 
                event.uid + 
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"
  
    assert_hey_urls_equal cal.hey_url, expected
  end

  def test_with_end_datetime_after_midnight
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,23,30,00,0),
      end_datetime:   Time.new(2024,9,7,1,30,00,0),
      title: "Holly's 19th birthday!",
      timezone: "UTC"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      end_datetime: event.end_datetime, 
      title: event.title, 
      timezone: event.timezone
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3A#{event.dtstart}" + 
                "%0ADTEND%3A#{event.dtend}" + 
                event.uid + 
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"
    
    assert_hey_urls_equal cal.hey_url, expected
  end
  
  def test_with_location
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      end_datetime:   Time.new(2024,9,6,15,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC",
      location: "Address, Postcode"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      end_datetime: event.end_datetime, 
      title: event.title, 
      timezone: event.timezone, 
      location: event.location
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3A#{event.dtstart}" + 
                "%0ADTEND%3A#{event.dtend}" + 
                event.uid + 
                "%0ALOCATION%3A#{event.location_encoded}" +
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end
  
  def test_with_url_without_description
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      end_datetime:   Time.new(2024,9,6,15,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC",
      url: "https://www.example.com/event-details"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      end_datetime: event.end_datetime, 
      title: event.title, 
      timezone: event.timezone,
      url: event.url
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3A#{event.dtstart}" + 
                "%0ADTEND%3A#{event.dtend}" + 
                "%0AURL%3A#{event.url_encoded}" +
                event.uid + 
                "%0ADESCRIPTION%3A#{event.url_encoded}" +
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end
  
  def test_with_url_and_description
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      end_datetime:   Time.new(2024,9,6,15,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC",
      url: "https://www.example.com/event-details",
      description: "Come join us for lots of fun & cake!"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      end_datetime: event.end_datetime, 
      title: event.title, 
      timezone: event.timezone,
      url: event.url,
      description: event.description
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3A#{event.dtstart}" + 
                "%0ADTEND%3A#{event.dtend}" + 
                "%0AURL%3A#{event.url_encoded}" +
                event.uid + 
                "%0ADESCRIPTION%3A#{event.description_encoded}\n\n#{event.url_encoded}" +
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end

  def test_description_with_newlines
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      end_datetime:   Time.new(2024,9,6,15,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC",
      description: "Test\n\nNewline"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      end_datetime: event.end_datetime, 
      title: event.title, 
      timezone: event.timezone,
      url: event.url,
      description: event.description
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3A#{event.dtstart}" + 
                "%0ADTEND%3A#{event.dtend}" + 
                event.uid + 
                "%0ADESCRIPTION%3A#{"Test\n\nNewline"}" +
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end
  
  def test_add_url_to_description_false_without_url
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      end_datetime:   Time.new(2024,9,6,15,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      end_datetime: event.end_datetime, 
      title: event.title, 
      timezone: event.timezone,
      add_url_to_description: false
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3A#{event.dtstart}" + 
                "%0ADTEND%3A#{event.dtend}" + 
                event.uid + 
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end
  
  def test_add_url_to_description_false_with_url
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      end_datetime:   Time.new(2024,9,6,15,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC",
      url: "https://www.example.com/event-details"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      end_datetime: event.end_datetime, 
      title: event.title, 
      timezone: event.timezone,
      url: event.url,
      add_url_to_description: false
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3A#{event.dtstart}" + 
                "%0ADTEND%3A#{event.dtend}" + 
                "%0AURL%3A#{event.url_encoded}" +
                event.uid + 
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end
  
  def test_with_all_attributes
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      end_datetime:   Time.new(2024,9,6,15,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC",
      location: "Address, Postcode",
      url: "https://www.example.com/event-details",
      description: "Come join us for lots of fun & cake!"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime,
      end_datetime: event.end_datetime,
      title: event.title, 
      timezone: event.timezone,
      url: event.url,
      location: event.location,
      description: event.description,
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3A#{event.dtstart}" + 
                "%0ADTEND%3A#{event.dtend}" + 
                "%0AURL%3A#{event.url_encoded}" +
                event.uid + 
                "%0ADESCRIPTION%3A#{event.description_encoded}\n\n#{event.url_encoded}" +
                "%0ALOCATION%3A#{event.location_encoded}" +
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end

  def test_all_day_spans_single_day
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      end_datetime:   Time.new(2024,9,6,15,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      end_datetime: event.end_datetime, 
      title: event.title,
      timezone: event.timezone,
      all_day: true
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3BVALUE%3DDATE%3A#{"20240906"}" + 
                "%0ADTEND%3BVALUE%3DDATE%3A#{"20240907"}" + 
                event.uid + 
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end

  def test_all_day_spans_multiple_days
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      end_datetime:   Time.new(2024,9,13,15,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      end_datetime: event.end_datetime, 
      title: event.title,
      timezone: event.timezone,
      all_day: true
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3BVALUE%3DDATE%3A#{"20240906"}" + 
                "%0ADTEND%3BVALUE%3DDATE%3A#{"20240914"}" + 
                event.uid + 
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end

  def test_all_day_without_end_date_is_single_day
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      title: event.title,
      timezone: event.timezone,
      all_day: true
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3BVALUE%3DDATE%3A#{"20240906"}" + 
                "%0ADTEND%3BVALUE%3DDATE%3A#{"20240907"}" + 
                event.uid + 
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end

  def test_all_day_end_date_is_plus_one_from_end_date
    event = TestEvent.new(
      start_datetime: Time.new(2024,9,6,12,30,00,0),
      end_datetime:   Time.new(2024,9,6,15,30,00,0),
      title: "Holly's 9th birthday!",
      timezone: "UTC"
    )

    cal = AddToCalendar::URLs.new(
      start_datetime: event.start_datetime, 
      end_datetime: event.end_datetime, 
      title: event.title,
      timezone: event.timezone,
      all_day: true
    )

    expected = "https://app.hey.com/calendar/ical_events/new" + 
                "?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0" +
                "%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT" + 
                "%0ASUMMARY%3A#{event.title_encoded}" + 
                "%0ADTSTAMP%3A#{event.dtstamp}" + 
                "%0ADTSTART%3BVALUE%3DDATE%3A#{"20240906"}" + 
                "%0ADTEND%3BVALUE%3DDATE%3A#{"20240907"}" + 
                event.uid + 
                "%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

    assert_hey_urls_equal cal.hey_url, expected
  end

  private

  class TestEvent
    attr_reader :start_datetime, :end_datetime, :title, :timezone, :location, :url, :description

    def initialize(start_datetime:, end_datetime: nil, title:, timezone:, location: nil, url: nil, description: nil)
      @start_datetime = start_datetime
      @end_datetime = end_datetime
      @title = title
      @timezone = timezone
      @location = location
      @url = url
      @description = description
    end

    def dtstart
      @start_datetime.utc.strftime('%Y%m%dT%H%M%SZ')
    end

    def dtstart_plus_one_hour
      one_hour = 60*60
      (@start_datetime + one_hour).utc.strftime('%Y%m%dT%H%M%SZ')
    end

    def dtend
      @end_datetime.utc.strftime('%Y%m%dT%H%M%SZ')
    end

    def uid
      "%0AUID%3A-#{url_encode(dtstart)}-#{url_encode(@title)}"
    end

    def dtstamp
      Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
    end

    def title_encoded
      url_encode(@title)
    end

    def location_encoded
      url_encode(@location)
    end

    def url_encoded
      url_encode(@url)
    end

    def description_encoded
      url_encode(@description)
    end
  end  
end
