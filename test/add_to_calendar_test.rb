require "test_helper"

class AddToCalendarTest < Minitest::Test

  def setup
    # TODO: DRY this in test_helper to be shared across all test files
    next_month = Time.now + 60*60*24*30
    @next_month_year = next_month.strftime('%Y')
    @next_month_month = next_month.strftime('%m')
    @next_month_day = next_month.strftime('%d')

    @title = "Holly's 8th Birthday!"
    @timezone = "Europe/London"
  end

  def test_that_it_has_a_version_number
    refute_nil ::AddToCalendar::VERSION
  end

  # TODO: test all validate_attributes

  def test_attribute_title_must_be_string
    assert_raises(ArgumentError) do
      AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: 1, timezone: @timezone)
    end
  end

  def test_attribute_title_must_not_be_blank
    assert_raises(ArgumentError) do
      AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: " ", timezone: @timezone)
    end
  end

  def test_attribute_location_must_be_string
    assert_raises(ArgumentError) do
      AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, location: 1)
    end
  end

  def test_attribute_description_must_be_string
    assert_raises(ArgumentError) do
      AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, description: 1)
    end
  end

  def test_attribute_start_datetime_must_be_time
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    assert cal.start_datetime.class == Time
  end

  def test_attribute_start_datetime_must_not_be_date
    # for now
    # update later to only allow if allday value is set
    assert_raises(ArgumentError) do
      AddToCalendar::URLs.new(start_datetime: Date.today, title: @title, timezone: @timezone, description: 1)
    end
  end

  def test_attribute_start_datetime_invalid
    assert_raises(ArgumentError) do
      AddToCalendar::URLs.new(start_datetime: 1, title: @title, timezone: @timezone)
    end
  end

  def test_attribute_end_datetime_invalid
    assert_raises(ArgumentError) do
      AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), end_datetime: 1, title: @title, timezone: @timezone)
    end
  end

  def test_attribute_end_datetime_must_be_greater_than_start_datetime
    assert_raises(ArgumentError) do
      AddToCalendar::URLs.new(
        start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
        end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day.to_i-1,13,30,00,0), 
        title: @title, 
        timezone: @timezone
      )
    end
  end

  def test_attribute_end_datetime_must_be_greater_than_start_datetime_not_equal
    assert_raises(ArgumentError) do
      AddToCalendar::URLs.new(
        start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
        end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
        title: @title, 
        timezone: @timezone
      )
    end
  end

  def test_format_datetime_google
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    formatted_datetime = cal.send(:format_date_google, Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0))
    assert formatted_datetime == "#{@next_month_year}#{@next_month_month}#{@next_month_day}T133000"
  end

  def test_tzinfo_object_created_successfully
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    assert cal.timezone.class == TZInfo::DataTimezone
  end

  def test_duration_seconds
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    seconds = cal.send(:duration_seconds, cal.start_datetime, cal.end_datetime)
    assert seconds == 12600 # 1700 - 1330 == 3h 30m == 210m == 12600s
  end

  def test_duration_seconds_more_than_a_day
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day.to_i+1,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    seconds = cal.send(:duration_seconds, cal.start_datetime, cal.end_datetime)
    assert seconds == 99000 # 24h + 3h + 30m == 27h 30m == 1650m == 99000s
  end
  
  def test_seconds_to_hours_minutes
    cal = AddToCalendar::URLs.new(
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
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day.to_i+1,17,00,00,0), 
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
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    string_without_newlines = cal.send(:newlines_to_html_br, "string without newlines")
    assert string_without_newlines = "string without newlines"

    string_with_newline = cal.send(:newlines_to_html_br, "string with\nnewline")
    assert string_with_newline = "string with<br>newline"

    string_with_newlines = cal.send(:newlines_to_html_br, "string\nwith\n\nnewlines")
    assert string_with_newline = "string<br>with<br><br>newline"
  end

end
