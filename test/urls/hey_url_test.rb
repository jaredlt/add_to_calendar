require "test_helper"

class HeyUrlTest < Minitest::Test
  def setup
    next_month = Time.now + 60*60*24*30
    @next_month_year = next_month.strftime('%Y')
    @next_month_month = next_month.strftime('%m')
    @next_month_day = next_month.strftime('%d')
  
    one_day = 1 * 24 * 60 * 60
    @next_month_year_plus_one_day = (next_month + one_day).strftime('%Y')
    @next_month_month_plus_one_day = (next_month + one_day).strftime('%m')
    @next_month_day_plus_one_day = (next_month + one_day).strftime('%d')
  
    seven_days = 7 * 24 * 60 * 60
    @next_month_year_plus_seven_days = (next_month + seven_days).strftime('%Y')
    @next_month_month_plus_seven_days = (next_month + seven_days).strftime('%m')
    @next_month_day_plus_seven_days = (next_month + seven_days).strftime('%d')
  
    @next_month_year_plus_eight_days = (next_month + seven_days + one_day).strftime('%Y')
    @next_month_month_plus_eight_days = (next_month + seven_days + one_day).strftime('%m')
    @next_month_day_plus_eight_days = (next_month + seven_days + one_day).strftime('%d')
    
    @prodid = Rails.application.class.name&.split("::")&.first
    @title = "Holly's 9th Birthday!"
    @timezone = "Europe/London"
    @url = "https://www.example.com/event-details"
    @location = "Flat 4, The Edge, 38 Smith-Dorrien St, London, N1 7GU"
    @description = "Come join us for lots of fun & cake!"
    @dtstamp = Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
    @dtstart = Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0).utc.strftime('%Y%m%dT%H%M%SZ')
    @dtend = Time.new(@next_month_year,@next_month_month,@next_month_day,14,30,00,0).utc.strftime('%Y%m%dT%H%M%SZ')
  
    @hour = 13
    @calendar_url_no_params = "https://app.hey.com/calendar/ical_events/new?ical_source=BEGIN%3AVCALENDAR%0ABEGIN%3AVEVENT"
    @calendar_url_with_defaults_required = "https://app.hey.com/calendar/ical_events/new?ical_source=BEGIN%3AVCALENDAR%0ABEGIN%3AVEVENT" + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@dtstart}" + "%0ADTEND%3A#{@dtend}"

    @url_end = "%0AEND:VEVENT%0AEND:VCALENDAR"
  
    # We need to freeze time on each test because DTSTAMP is generated via Time.now
    Timecop.freeze(Time.now)
  end
  

  def teardown
    Timecop.return
  end
  
  def test_without_end_datetime
    # should set end as start + 1 hour
    cal = AddToCalendar::URLs.new(
      start_datetime: @dtstart, 
      title: @title, 
      timezone: @timezone)
    assert cal.hey_url == @calendar_url_with_defaults_required + @url_end
  end

  def test_with_end_datetime
    cal = AddToCalendar::URLs.new(
      start_datetime: @dtstart, 
      end_datetime: @dtend, 
      title: @title, 
      timezone: @timezone
    )
    assert cal.hey_url ==  @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@dtstart}" + "%0ADTEND%3A#{@dtend}" + @url_end
  end

  def test_with_end_datetime_after_midnight
    cal = AddToCalendar::URLs.new(
      start_datetime: @dtstart, 
      end_datetime: @dtend, 
      title: @title, 
      timezone: @timezone
    )
    assert cal.hey_url ==  @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@dtstart}" + "%0ADTEND%3A#{@dtend}" + @url_end
  end
  
  def test_with_location
    cal = AddToCalendar::URLs.new(
      start_datetime: @dtstart, 
      title: @title, 
      timezone: @timezone, 
      location: @location)
    assert cal.hey_url == @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@dtstart}" + "%0ADTEND%3A#{@dtend}" + "%0ALOCATION%3A#{@location}" + @url_end
  end
  
  def test_with_url_without_description
    cal = AddToCalendar::URLs.new(
      start_datetime: @dtstart, 
      title: @title, 
      timezone: @timezone,
      url: @url)
    assert cal.hey_url == @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@dtstart}" + "%0ADTEND%3A#{@dtend}" + "%0AURL%3A#{@url}" + @url_end
  end
  
  def test_with_url_and_description
    cal = AddToCalendar::URLs.new(
      start_datetime: @dtstart, 
      title: @title, 
      timezone: @timezone, 
      url: @url, 
      description: @description)

    assert cal.hey_url == @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@dtstart}" + "%0ADTEND%3A#{@dtend}" + "%0ADESCRIPTION%3A#{@description}" + "%0AURL%3A#{@url}" + @url_end
  end

  def test_description_with_newlines
    # final *.ics file must include `\n`
    # which means the string output must be `\\n`
    cal = AddToCalendar::URLs.new(
    start_datetime: @dtstart, 
    title: @title, 
    timezone: @timezone, 
    description: "Come join us for lots of fun & cake!\n\nBring a towel!")

    assert cal.hey_url == @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@dtstart}" + "%0ADTEND%3A#{@dtend}" + "%0ADESCRIPTION%3ACome%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21\\n\\nBring%20a%20towel%21" + @url_end
  end
  
  def test_add_url_to_description_false_without_url
    cal = AddToCalendar::URLs.new(
      start_datetime: @dtstart, 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
    )
    assert cal.hey_url == @calendar_url_with_defaults_required  + @url_end
  end
  
  def test_add_url_to_description_false_with_url
    cal = AddToCalendar::URLs.new(
      start_datetime: @dtstart, 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
      url: @url,
    )
    assert cal.hey_url == @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@dtstart}" + "%0ADTEND%3A#{@dtend}" + @url + @url_end
  end
  
  def test_with_all_attributes
    cal = AddToCalendar::URLs.new(
      start_datetime: @dtstart,
      end_datetime: @dtend,
      title: @title, 
      timezone: @timezone,
      url: @url,
      location: @location,
      description: @description,
    )
    assert cal.hey_url == @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@dtstart}" + "%0ADTEND%3A#{@dtend}" + "%0ADESCRIPTION%3A#{@description}" + "%0AURL%3A#{@url}" + "%0ALOCATION%3A#{@location}" + @url_end
  end

  def test_all_day_spans_single_day
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      all_day: true,
      title: @title, 
      timezone: @timezone
    )
    ical = @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@next_month_year}#{@next_month_month}#{@next_month_day}" + "%0ADTEND%3A#{@next_month_year_plus_one_day}#{@next_month_month_plus_one_day}#{@next_month_day_plus_one_day}" + @url_end
    assert cal.hey_url == ical
  end

  def test_all_day_spans_multiple_days
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year_plus_seven_days,@next_month_month_plus_seven_days,@next_month_day_plus_seven_days,17,00,00,0), 
      all_day: true,
      title: @title, 
      timezone: @timezone
    )
    ical = @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@next_month_year}#{@next_month_month}#{@next_month_day}" + "%0ADTEND%3A#{@next_month_year_plus_eight_days}#{@next_month_month_plus_eight_days}#{@next_month_day_plus_eight_days}" + @url_end
    assert cal.hey_url == ical
  end

  def test_all_day_without_end_date_is_single_day
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      all_day: true,
      title: @title, 
      timezone: @timezone
    )
    ical = @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@next_month_year}#{@next_month_month}#{@next_month_day}" + "%0ADTEND%3A#{@next_month_year_plus_one_day}#{@next_month_month_plus_one_day}#{@next_month_day_plus_one_day}" + @url_end

    assert cal.hey_url == ical
  end

  def test_all_day_end_date_is_plus_one_from_end_date
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      all_day: true,
      title: @title, 
      timezone: @timezone
    )
    ical = @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@next_month_year}#{@next_month_month}#{@next_month_day}" + "%0ADTEND%3A#{@next_month_year_plus_one_day}#{@next_month_month_plus_one_day}#{@next_month_day_plus_one_day}" + @url_end

    assert cal.hey_url == ical
  end

  def test_organizer
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,14,30,00,0), 
      title: @title, 
      timezone: @timezone,
      organizer: {
        name: "Jared Turner",
        email: "jared@example.com"
      }
    )
    ical =  @calendar_url_no_params + "%0ASUMMARY%3A#{@title}" + "%0ADTSTAMP%3A#{@dtstamp}" + "%0ADTSTART%3A#{@next_month_year}#{@next_month_month}#{@next_month_day}" + "%0ADTEND%3A#{@next_month_year}#{@next_month_month}#{@next_month_day}" + "%0AORGANIZER%3AJared%2520Turner%3Amailto%3Ajared%40example.com" + @url_end

    assert cal.hey_url == ical
  end
  
end
