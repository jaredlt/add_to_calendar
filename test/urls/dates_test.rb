require "test_helper"

class DatessTest < Minitest::Test

  def setup
    # TODO: DRY this in test_helper to be shared across all test files
    next_month = Time.now + 60*60*24*30
    @next_month_year = next_month.strftime('%Y')
    @next_month_month = next_month.strftime('%m')
    @next_month_day = next_month.strftime('%d')

    @title = "Holly's 8th Birthday!"

    @tz_london = "Europe/London"
    @tz_new_york = "America/New_York"

  end
  
  def test_utc_datetime
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @tz_london)
    t = cal.send(:utc_datetime, Time.new(2020,05,11,13,30,00))
    assert t == "20200511T123000Z"
  end

  def test_utc_datetime_new_york
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @tz_new_york)
    t = cal.send(:utc_datetime, Time.new(2020,05,11,13,30,00))
    assert t == "20200511T173000Z"
  end

  def test_utc_datetime_ignores_offset
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @tz_london)
    t = cal.send(:utc_datetime, Time.new(2020,05,11,13,30,00, "+05:00"))
    assert t == "20200511T123000Z"
  end

end