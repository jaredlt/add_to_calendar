require "test_helper"

class GoogleUrlTest < Minitest::Test
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

    @url_with_defaults_required = "https://www.google.com/calendar/render?action=TEMPLATE" +
                                  "&text=Holly%27s%208th%20Birthday%21" + 
                                  "&dates=#{@next_month_year}#{@next_month_month}#{@next_month_day}T133000/#{@next_month_year}#{@next_month_month}#{@next_month_day}T143000" + 
                                  "&ctz=Europe/London"
  end

  def test_with_only_required_attributes
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    assert cal.google_url == @url_with_defaults_required
  end

  def test_without_end_datetime
    # should set end as start + 1 hour
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    assert cal.google_url == "https://www.google.com/calendar/render?action=TEMPLATE" +
                            "&text=Holly%27s%208th%20Birthday%21" + 
                            "&dates=#{@next_month_year}#{@next_month_month}#{@next_month_day}T133000/#{@next_month_year}#{@next_month_month}#{@next_month_day}T143000" + 
                            "&ctz=Europe/London"
  end

  def test_with_end_datetime
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0),
      title: @title, 
      timezone: @timezone
    )
    assert cal.google_url == "https://www.google.com/calendar/render?action=TEMPLATE" +
                             "&text=Holly%27s%208th%20Birthday%21" + 
                             "&dates=#{@next_month_year}#{@next_month_month}#{@next_month_day}T133000/#{@next_month_year}#{@next_month_month}#{@next_month_day}T170000" +
                             "&ctz=Europe/London"
  end

  def test_with_location
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, location: @location)
    assert cal.google_url == @url_with_defaults_required + "&location=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU"
  end

  def test_with_url_without_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url)
    assert cal.google_url == @url_with_defaults_required + "&details=https%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_with_url_and_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url, description: @description)
    assert cal.google_url == @url_with_defaults_required + "&details=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_description_with_newlines_from_user_input
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone, 
      url: @url, 
      description: "Come join us for lots of fun & cake!\n\nDon't forget your swimwear!")
    assert cal.google_url == @url_with_defaults_required + "&details=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0ADon%27t%20forget%20your%20swimwear%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_add_url_to_description_false_without_url
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
    )
    assert cal.google_url == @url_with_defaults_required
  end

  def test_add_url_to_description_false_with_url
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
      url: @url,
    )
    assert cal.google_url == @url_with_defaults_required
  end

  def test_with_all_attributes
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone,
      url: @url,
      location: @location,
      description: @description,
    )
    assert cal.google_url == "https://www.google.com/calendar/render?action=TEMPLATE" +
                             "&text=Holly%27s%208th%20Birthday%21" + 
                             "&dates=#{@next_month_year}#{@next_month_month}#{@next_month_day}T133000/#{@next_month_year}#{@next_month_month}#{@next_month_day}T170000" +
                             "&ctz=Europe/London" + 
                             "&location=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU" + 
                             "&details=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details"
  end
  
end
