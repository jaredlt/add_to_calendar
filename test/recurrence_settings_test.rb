require "test_helper"

class RecurrenceSettingTest < Minitest::Test
  def test_to_rrule_monthly_event
    recurrence = {
      freq: 'monthly',
      interval: 1,
      count: 3,
      bymonthday: 3
    }

    assert_equal(
      AddToCalendar::RecurrenceSettings.new(recurrence).to_rrule,
      "RRULE:BYMONTHDAY=#{recurrence[:bymonthday]};COUNT=#{recurrence[:count]};FREQ=#{recurrence[:freq].upcase};INTERVAL=#{recurrence[:interval]}"
    )

    recurrence = {
      freq: 'monthly',
      interval: 1,
      end_at: '20211013T164252Z',
      monthly_week: 3,
      monthly_week_day: 2
    }

    assert_equal(
      AddToCalendar::RecurrenceSettings.new(recurrence).to_rrule,
      "RRULE:BYDAY=#{recurrence[:monthly_week]}Tu;FREQ=#{recurrence[:freq].upcase};INTERVAL=#{recurrence[:interval]};UNTIL=#{recurrence[:end_at]}"
    )
  end

  def test_to_rrule_daily_event
    recurrence = {
      freq: 'daily',
      interval: 1,
      count: 3,
      byday: 2
    }

    assert_equal(
      AddToCalendar::RecurrenceSettings.new(recurrence).to_rrule,
      "RRULE:BYDAY=TU;COUNT=#{recurrence[:count]};FREQ=#{recurrence[:freq].upcase};INTERVAL=#{recurrence[:interval]}"
    )
  end

  def test_to_rrule_weekly_event
    recurrence = {
      freq: 'weekly',
      interval: 1,
      count: 3,
      byday: [3, 2, 1]
    }

    assert_equal(
      AddToCalendar::RecurrenceSettings.new(recurrence).to_rrule,
      "RRULE:BYDAY=MO,TU,WE;COUNT=#{recurrence[:count]};FREQ=#{recurrence[:freq].upcase};INTERVAL=#{recurrence[:interval]}"
    )
  end
end
