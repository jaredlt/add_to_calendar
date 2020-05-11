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
                                  "&text=Holly%27s+8th+Birthday%21" + 
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
                            "&text=Holly%27s+8th+Birthday%21" + 
                            "&dates=#{@next_month_year}#{@next_month_month}#{@next_month_day}T133000/#{@next_month_year}#{@next_month_month}#{@next_month_day}T143000" + 
                            "&ctz=Europe/London"
  end

  def test_with_location
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, location: @location)
    assert cal.google_url == @url_with_defaults_required + "&location=Flat+4%2C+The+Edge%2C+38+Smith-Dorrien+St%2C+London%2C+N1+7GU"
  end

  def test_with_url_without_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url)
    assert cal.google_url == @url_with_defaults_required + "&details=https%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_with_url_and_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url, description: @description)
    assert cal.google_url == @url_with_defaults_required + "&details=Come+join+us+for+lots+of+fun+%26+cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details"
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
      title: @title, 
      timezone: @timezone,
      url: @url,
      location: @location,
      description: @description,
    )
    assert cal.google_url == @url_with_defaults_required + "&location=Flat+4%2C+The+Edge%2C+38+Smith-Dorrien+St%2C+London%2C+N1+7GU&details=Come+join+us+for+lots+of+fun+%26+cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details"
  end
  
end
