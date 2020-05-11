require "test_helper"

class IcalUrlTest < Minitest::Test
  def setup
    next_month = Time.now + 60*60*24*30
    @next_month_year = next_month.strftime('%Y')
    @next_month_month = next_month.strftime('%m')
    @next_month_day = next_month.strftime('%d')

    @title = "Holly's 8th Birthday!"
    @timezone = "Europe/London"
    @url = "https://www.example.com/event-details"
    @location = "Flat 4, The Edge, 38 Smith-Dorrien St, London, N1 7GU"
    @description = "Come join us for lots of fun & cake!"

    @url_with_defaults_required = "data:text/calendar;charset=utf8,BEGIN:VCALENDAR%0AVERSION:2.0%0ABEGIN:VEVENT" +
                                  "%0ADTSTART=20200610T123000Z" + 
                                  "%0ADTEND=20200610T133000Z" + 
                                  "%0ASUMMARY=Holly%27s%208th%20Birthday%21"
    @url_end = "%0AEND:VEVENT%0AEND:VCALENDAR"

    # "%0AUID=-20200610T123000Z-Holly%27s%208th%20Birthday%21%0AEND:VEVENT%0AEND:VCALENDAR"
  end

  def test_with_only_required_attributes
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    uid = "%0AUID=-#{cal.send(:utc_datetime, cal.start_datetime)}-#{url_encode(cal.title)}"
    assert cal.ical_url == @url_with_defaults_required + uid + @url_end
  end
  
  def test_without_end_datetime
    # should set end as start + 1 hour
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    uid = "%0AUID=-#{cal.send(:utc_datetime, cal.start_datetime)}-#{url_encode(cal.title)}"
    assert cal.ical_url == "data:text/calendar;charset=utf8,BEGIN:VCALENDAR%0AVERSION:2.0%0ABEGIN:VEVENT" +
    "%0ADTSTART=20200610T123000Z" + 
    "%0ADTEND=20200610T133000Z" + 
    "%0ASUMMARY=Holly%27s%208th%20Birthday%21" + 
    uid + 
    @url_end
  end
  
  def test_with_location
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, location: @location)
    uid = "%0AUID=-#{cal.send(:utc_datetime, cal.start_datetime)}-#{url_encode(cal.title)}"
    assert cal.ical_url == @url_with_defaults_required + "%0ALOCATION=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU" + uid + @url_end
  end
  
  def test_with_url_without_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url)
    uid = "%0AUID=-#{url_encode(cal.url)}"
    assert cal.ical_url == @url_with_defaults_required + "%0AURL=https%3A%2F%2Fwww.example.com%2Fevent-details%0ADESCRIPTION=https%3A%2F%2Fwww.example.com%2Fevent-details" + uid + @url_end
  end
  
  def test_with_url_and_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url, description: @description)
    uid = "%0AUID=-#{url_encode(cal.url)}"
    assert cal.ical_url == @url_with_defaults_required + "%0AURL=https%3A%2F%2Fwww.example.com%2Fevent-details%0ADESCRIPTION=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21\n\nhttps%3A%2F%2Fwww.example.com%2Fevent-details" + uid + @url_end
  end
  
  def test_add_url_to_description_false_without_url
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
    )
    uid = "%0AUID=-#{cal.send(:utc_datetime, cal.start_datetime)}-#{url_encode(cal.title)}"
    assert cal.ical_url == @url_with_defaults_required + uid + @url_end
  end
  
  def test_add_url_to_description_false_with_url
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
      url: @url,
    )
    uid = "%0AUID=-#{url_encode(cal.url)}"
    assert cal.ical_url == @url_with_defaults_required + "%0AURL=https%3A%2F%2Fwww.example.com%2Fevent-details" + uid + @url_end
  end
  
  def test_with_all_attributes
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      url: @url,
      location: @location,
      description: @description,
    )
    uid = "%0AUID=-#{url_encode(cal.url)}"
    assert cal.ical_url == @url_with_defaults_required + "%0AURL=https%3A%2F%2Fwww.example.com%2Fevent-details%0ADESCRIPTION=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21\n\nhttps%3A%2F%2Fwww.example.com%2Fevent-details%0ALOCATION=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU" + uid + @url_end
  end
  
end
