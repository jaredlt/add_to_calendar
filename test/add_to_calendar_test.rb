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

    @url_with_defaults_required = "https://www.google.com/calendar/render?action=TEMPLATE" +
                                  "&text=Holly%27s+8th+Birthday%21" + 
                                  "&dates=#{@next_month_year}#{@next_month_month}#{@next_month_day}T133000/#{@next_month_year}#{@next_month_month}#{@next_month_day}T143000" + 
                                  "&ctz=Europe/London"
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

  def test_format_datetime
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    formatted_datetime = cal.send(:format_date, Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0))
    assert formatted_datetime == "#{@next_month_year}#{@next_month_month}#{@next_month_day}T133000"
  end

  def test_tzinfo_object_created_successfully
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    assert cal.timezone.class == TZInfo::DataTimezone
  end

end
