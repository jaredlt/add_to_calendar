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

    @title = "Holly's 8th Birthday!"
    @timezone = "Europe/London"
    @url = "https://www.example.com/event-details"
    @location = "Flat 4, The Edge, 38 Smith-Dorrien St, London, N1 7GU"
    @description = "Come join us for lots of fun & cake!"

    @url_with_defaults_required = "http://calendar.yahoo.com/?v=60&view=d&type=20" +
                                  "&title=Holly%27s%208th%20Birthday%21" + 
                                  "&st=20200610T123000Z" + 
                                  "&dur=0100"

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
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    assert cal.yahoo_url == "http://calendar.yahoo.com/?v=60&view=d&type=20" +
                            "&title=Holly%27s%208th%20Birthday%21" + 
                            "&st=#{@next_month_year}#{@next_month_month}#{@next_month_day}T123000Z" + 
                            "&dur=0100"
  end

  def test_with_location
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, location: @location)
    assert cal.yahoo_url == @url_with_defaults_required + "&in_loc=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU"
  end

  def test_with_url_without_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url)
    assert cal.yahoo_url == @url_with_defaults_required + "&desc=https%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_with_url_and_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url, description: @description)
    assert cal.yahoo_url == @url_with_defaults_required + "&desc=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details"
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
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      url: @url,
      location: @location,
      description: @description,
    )
    assert cal.yahoo_url == @url_with_defaults_required + "&desc=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details&in_loc=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU"
  end
  
end
