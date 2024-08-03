require "test_helper"

class YahooUrlTest < Minitest::Test
  def setup
    next_month = Time.now + 60*60*24*30
    @next_month_year = next_month.strftime('%Y')
    @next_month_month = next_month.strftime('%m')
    @next_month_day = next_month.strftime('%d')

    @hour = 13
    @minute = 30
    @second = 00

    one_day = 1 * 24 * 60 * 60
    @next_month_year_plus_one_day = (next_month + one_day).strftime('%Y')
    @next_month_month_plus_one_day = (next_month + one_day).strftime('%m')
    @next_month_day_plus_one_day = (next_month + one_day).strftime('%d')

    seven_days = 7 * 24 * 60 * 60
    @next_month_year_plus_seven_days = (next_month + seven_days).strftime('%Y')
    @next_month_month_plus_seven_days = (next_month + seven_days).strftime('%m')
    @next_month_day_plus_seven_days = (next_month + seven_days).strftime('%d')

    @title = "Holly's 8th Birthday!"
    @timezone = "UTC"
    @url = "https://www.example.com/event-details"
    @location = "Flat 4, The Edge, 38 Smith-Dorrien St, London, N1 7GU"
    @description = "Come join us for lots of fun & cake!"

    @url_with_defaults_required = "https://calendar.yahoo.com/?v=60" +
                                  "&TITLE=Holly%27s%208th%20Birthday%21" + 
                                  "&ST=#{@next_month_year}#{@next_month_month}#{@next_month_day}T#{@hour}3000Z" + 
                                  "&DUR=0100"

  end

  def test_with_only_required_attributes
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,@hour,@minute,@second), 
      title: @title, 
      timezone: @timezone
    )
    assert cal.yahoo_url == @url_with_defaults_required
  end

  def test_without_end_datetime
    # should set duration as 1 hour
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,@hour,30,00,0), title: @title, timezone: @timezone)
    assert cal.yahoo_url == "https://calendar.yahoo.com/?v=60" +
                            "&TITLE=Holly%27s%208th%20Birthday%21" + 
                            "&ST=#{@next_month_year}#{@next_month_month}#{@next_month_day}T#{@hour}3000Z" + 
                            "&DUR=0100"
  end

  def test_with_end_datetime
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,@hour,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,@hour+4,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    assert cal.yahoo_url == "https://calendar.yahoo.com/?v=60" +
                            "&TITLE=Holly%27s%208th%20Birthday%21" + 
                            "&ST=#{@next_month_year}#{@next_month_month}#{@next_month_day}T#{@hour}3000Z" + 
                            "&DUR=0330"
  end

  def test_with_end_datetime_crossing_over_midnight
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year_plus_one_day,@next_month_month_plus_one_day,@next_month_day_plus_one_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    assert cal.yahoo_url == "https://calendar.yahoo.com/?v=60" +
                            "&TITLE=Holly%27s%208th%20Birthday%21" + 
                            "&ST=#{@next_month_year}#{@next_month_month}#{@next_month_day}T#{@hour}3000Z" + 
                            "&DUR=2730"
  end

  def test_with_location
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, location: @location)
    assert cal.yahoo_url == @url_with_defaults_required + "&in_loc=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU"
  end

  def test_with_url_without_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url)
    assert cal.yahoo_url == @url_with_defaults_required + "&DESC=https%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_with_url_and_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url, description: @description)
    assert cal.yahoo_url == @url_with_defaults_required + "&DESC=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_description_with_newlines_from_user_input
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone, 
      url: @url, 
      description: "Come join us for lots of fun & cake!\n\nDon't forget your swimwear!"
    )
    assert cal.yahoo_url == @url_with_defaults_required + "&DESC=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0ADon%27t%20forget%20your%20swimwear%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_add_url_to_description_false_without_url
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
    )
    assert cal.yahoo_url == @url_with_defaults_required
  end

  def test_add_url_to_description_false_with_url
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
      url: @url,
    )
    assert cal.yahoo_url == @url_with_defaults_required
  end

  def test_with_all_attributes
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,@hour,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,@hour+4,00,00,0), 
      title: @title, 
      timezone: @timezone,
      url: @url,
      location: @location,
      description: @description,
    )
    assert cal.yahoo_url == "https://calendar.yahoo.com/?v=60" +
                            "&TITLE=Holly%27s%208th%20Birthday%21" + 
                            "&ST=#{@next_month_year}#{@next_month_month}#{@next_month_day}T#{@hour}3000Z" + 
                            "&DUR=0330" +
                            "&DESC=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details" + 
                            "&in_loc=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU"
  end

  def test_all_day_spans_single_day
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0),
      all_day: true,
      title: @title, 
      timezone: @timezone
    )
    assert cal.yahoo_url == "https://calendar.yahoo.com/?v=60" +
                            "&TITLE=Holly%27s%208th%20Birthday%21" + 
                            "&ST=#{@next_month_year}#{@next_month_month}#{@next_month_day}" + 
                            "&ET=#{@next_month_year}#{@next_month_month}#{@next_month_day}" + 
                            "&DUR=allday"
  end

  def test_all_day_spans_multiple_days
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year_plus_seven_days,@next_month_month_plus_seven_days,@next_month_day_plus_seven_days,17,00,00,0),
      all_day: true,
      title: @title, 
      timezone: @timezone
    )
    assert cal.yahoo_url == "https://calendar.yahoo.com/?v=60" +
                            "&TITLE=Holly%27s%208th%20Birthday%21" + 
                            "&ST=#{@next_month_year}#{@next_month_month}#{@next_month_day}" + 
                            "&ET=#{@next_month_year_plus_seven_days}#{@next_month_month_plus_seven_days}#{@next_month_day_plus_seven_days}" + 
                            "&DUR=allday"
  end

  def test_all_day_without_end_date_is_single_day
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      all_day: true,
      title: @title, 
      timezone: @timezone
    )
    assert cal.yahoo_url == "https://calendar.yahoo.com/?v=60" +
                            "&TITLE=Holly%27s%208th%20Birthday%21" + 
                            "&ST=#{@next_month_year}#{@next_month_month}#{@next_month_day}" + 
                            "&ET=#{@next_month_year}#{@next_month_month}#{@next_month_day}" + 
                            "&DUR=allday"
  end
  
end
