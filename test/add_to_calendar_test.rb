require "test_helper"

class AddToCalendarLinksTest < Minitest::Test

  def setup
    # TODO: DRY this in test_helper to be shared across all test files
    next_month = Time.now + 60*60*24*30
    @next_month_year = next_month.strftime('%Y')
    @next_month_month = next_month.strftime('%m')
    @next_month_day = next_month.strftime('%d')
    
    next_month_day_after = (next_month + 60*60*24)
    @next_month_next_year = next_month_day_after.strftime('%Y')
    @next_month_next_month = next_month_day_after.strftime('%m')
    @next_month_next_day = next_month_day_after.strftime('%d')

    @title = "Holly's 8th Birthday!"
    @timezone = "Europe/London"
  end

  def test_that_it_has_a_version_number
    refute_nil ::AddToCalendarLinks::VERSION
  end

  # TODO: test all validate_attributes

  def test_attribute_title_must_be_string
    assert_raises(ArgumentError) do
      AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: 1, timezone: @timezone)
    end
  end

  def test_attribute_title_must_not_be_blank
    assert_raises(ArgumentError) do
      AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: " ", timezone: @timezone)
    end
  end

  def test_attribute_location_must_be_string
    assert_raises(ArgumentError) do
      AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, location: 1)
    end
  end

  def test_attribute_description_must_be_string
    assert_raises(ArgumentError) do
      AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, description: 1)
    end
  end

  def test_attribute_start_datetime_must_be_time
    cal = AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    assert cal.start_datetime.class == Time
  end

  def test_attribute_start_datetime_must_not_be_date
    # for now
    # update later to only allow if allday value is set
    assert_raises(ArgumentError) do
      AddToCalendarLinks::URLs.new(start_datetime: Date.today, title: @title, timezone: @timezone, description: 1)
    end
  end

  def test_attribute_start_datetime_invalid
    assert_raises(ArgumentError) do
      AddToCalendarLinks::URLs.new(start_datetime: 1, title: @title, timezone: @timezone)
    end
  end

  def test_attribute_end_datetime_invalid
    assert_raises(ArgumentError) do
      AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), end_datetime: 1, title: @title, timezone: @timezone)
    end
  end

  def test_attribute_end_datetime_must_be_greater_than_start_datetime
    assert_raises(ArgumentError) do
      AddToCalendarLinks::URLs.new(
        start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
        end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day.to_i-1,13,30,00,0), 
        title: @title, 
        timezone: @timezone
      )
    end
  end

  def test_attribute_end_datetime_must_be_greater_than_start_datetime_not_equal
    assert_raises(ArgumentError) do
      AddToCalendarLinks::URLs.new(
        start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
        end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
        title: @title, 
        timezone: @timezone
      )
    end
  end

  def test_format_datetime_google
    cal = AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    formatted_datetime = cal.send(:format_date_google, Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0))
    assert formatted_datetime == "#{@next_month_year}#{@next_month_month}#{@next_month_day}T133000"
  end

  def test_tzinfo_object_created_successfully
    cal = AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    assert cal.timezone.class == TZInfo::DataTimezone
  end

  def test_duration_seconds
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    seconds = cal.send(:duration_seconds, cal.start_datetime, cal.end_datetime)
    assert seconds == 12600 # 1700 - 1330 == 3h 30m == 210m == 12600s
  end

  def test_duration_seconds_more_than_a_day
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_next_year,@next_month_next_month,@next_month_next_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    seconds = cal.send(:duration_seconds, cal.start_datetime, cal.end_datetime)
    assert seconds == 99000 # 24h + 3h + 30m == 27h 30m == 1650m == 99000s
  end
  
  def test_seconds_to_hours_minutes
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    duration_seconds = cal.send(:duration_seconds, cal.start_datetime, cal.end_datetime)
    duration = cal.send(:seconds_to_hours_minutes, duration_seconds)
    assert duration == "0330"
  end

  def test_seconds_to_hours_minutes_more_than_a_day
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_next_year,@next_month_next_month,@next_month_next_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    duration_seconds = cal.send(:duration_seconds, cal.start_datetime, cal.end_datetime)
    duration = cal.send(:seconds_to_hours_minutes, duration_seconds)

    assert duration == "2730"
  end

  def test_newlines_convert_to_html_br
    # Office365 & Outlook.com don't accept newlines for multi-line bodies
    # instead we must convert them to <br> tags
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    string_without_newlines = cal.send(:newlines_to_html_br, "string without newlines")
    assert string_without_newlines == "string without newlines"

    string_with_newline = cal.send(:newlines_to_html_br, "string with\nnewline")
    assert string_with_newline == "string with<br>newline"

    string_with_newlines = cal.send(:newlines_to_html_br, "string\nwith\n\nnewlines")
    assert string_with_newlines == "string<br>with<br><br>newlines"
  end

  def test_ical_description_url_encoded_with_newlines
    # final *.ics file must include `\n`
    # which means the string output must be `\\n` (not url encoded)
    # this is to ensure it works when included in data-uris
    # this method should:
    # url encode all characters except newlines \n
    # update all newlines \n to \\n
    event_attributes = {
      start_datetime: Time.new(2020,12,12,9,00,00,0), # required
      end_datetime: Time.new(2020,12,12,17,00,00,0),
      title: "Ruby Conference", # required
      timezone: 'America/New_York', # required
      location: "20 W 34th St, New York, NY 10001", 
      url: "https://www.ruby-lang.org/en/",
      description: "Join us to learn\n\nall about Ruby.",
      add_url_to_description: true # defaults to true
    }
    cal = AddToCalendarLinks::URLs.new(**event_attributes)

    string_without_newlines = cal.send(:url_encode_ical, "string without newlines")
    assert string_without_newlines == "string%20without%20newlines"

    string_with_newline = cal.send(:url_encode_ical, "string with\nnewline")
    assert string_with_newline == "string%20with\\nnewline"

    string_with_newlines = cal.send(:url_encode_ical, "string\nwith\n\nnewlines")
    assert string_with_newlines == "string\\nwith\\n\\nnewlines"
  end

  def test_ical_escapes_special_characters
    # per https://tools.ietf.org/html/rfc5545#section-3.3.11
    # special characters are: BACKSLASH, COMMA, SEMICOLON, NEWLINE
    event_attributes = {
      start_datetime: Time.new(2020,12,12,9,00,00,0), # required
      end_datetime: Time.new(2020,12,12,17,00,00,0),
      title: "Ruby Conference; Rails Conference", # required
      timezone: 'America/New_York', # required
      location: "20 W 34th St, New York, NY 10001", 
      url: "https://www.ruby-lang.org/en/",
      description: "Join us to learn all about Ruby \\ Rails.",
      add_url_to_description: true # defaults to true
    }
    cal = AddToCalendarLinks::URLs.new(**event_attributes)

    backslash = cal.send(:url_encode_ical, "Ruby\\Rails")
    assert backslash == "Ruby%5C%5CRails" # url_encoded `\\`` where %5C == \

    comma = cal.send(:url_encode_ical, "Ruby,Rails")
    assert comma == "Ruby%5C%2CRails" # url_encoded `\,` where %2C == ,

    semicolon = cal.send(:url_encode_ical, "Ruby;Rails")
    assert semicolon == "Ruby%5C%3BRails" # url_encoded `\;` where %3B == ;
  end

  def test_url_encode_ical_removes_html
    event_attributes = {
      start_datetime: Time.new(2020,12,12,9,00,00,0),
      end_datetime: Time.new(2020,12,12,17,00,00,0),
      title: "Ruby Conference; Rails Conference",
      timezone: 'America/New_York',
      description: 'Join us to <b>learn</b> all about <img />Ruby \\ <div>Rails.</div>',
      strip_html: false
    }
    cal = AddToCalendarLinks::URLs.new(**event_attributes)

    description_encoded = cal.send(:url_encode_ical, event_attributes[:description], strip_html: true)
    assert description_encoded == "Join%20us%20to%20learn%20all%20about%20Ruby%20%5C%5C%20Rails." 
  end

  def test_ical_doesnt_remove_html_by_default
    event_attributes = {
      start_datetime: Time.new(2020,12,12,9,00,00,0),
      end_datetime: Time.new(2020,12,12,17,00,00,0),
      title: "Ruby Conference; Rails Conference",
      timezone: 'America/New_York',
      description: 'Join us to <b>learn</b> all about <img />Ruby \\ <div>Rails.</div>'
    }
    cal = AddToCalendarLinks::URLs.new(**event_attributes)

    description_encoded = cal.send(:url_encode_ical, event_attributes[:description])
    assert description_encoded == "Join%20us%20to%20%3Cb%3Elearn%3C%2Fb%3E%20all%20about%20%3Cimg%20%2F%3ERuby%20%5C%5C%20%3Cdiv%3ERails.%3C%2Fdiv%3E" 
  end

  def test_rn_newline_should_be_detected_converted_and_escaped
    # \r\n should be converted to \n so that we can also escape them to \\n
    event_attributes = {
      start_datetime: Time.new(2020,12,12,9,00,00,0), # required
      end_datetime: Time.new(2020,12,12,17,00,00,0),
      title: "Ruby Conference; Rails Conference", # required
      timezone: 'America/New_York', # required
      location: "20 W 34th St, New York, NY 10001", 
      url: "https://www.ruby-lang.org/en/",
      description: "Join us to learn all about Ruby \\ Rails.",
      add_url_to_description: true # defaults to true
    }
    cal = AddToCalendarLinks::URLs.new(**event_attributes)

    rn_newline = cal.send(:url_encode_ical, "rn\r\nnewline")
    assert rn_newline == "rn\\nnewline"
  end

  def test_calling_class_methods_should_not_mutate_initialized_attributes
    event_attributes = {
      start_datetime: Time.new(2020,12,12,9,00,00,0), # required
      end_datetime: Time.new(2020,12,12,17,00,00,0),
      title: "Ruby Conference; Rails Conference", # required
      timezone: 'America/New_York', # required
      location: "20 W 34th St, New York, NY 10001", 
      url: "https://www.ruby-lang.org/en/",
      description: "Join us to learn\nall about Ruby \\ Rails.",
      add_url_to_description: true # defaults to true
    }
    cal = AddToCalendarLinks::URLs.new(**event_attributes)
    cal.apple_url
    assert cal.location == "20 W 34th St, New York, NY 10001"
    assert cal.location != "20 W 34th St\\, New York\\, NY 10001" # to show what it shouldn't look like
    cal.google_url
    assert cal.location == "20 W 34th St, New York, NY 10001"
  end

end
