# AddToCalendar

A ruby gem to generate 'Add To Calendar' URLs for Google, Apple, Office 365*, Outlook and Yahoo calendars.

*Office 365 not yet available

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'add_to_calendar'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install add_to_calendar

## Requirements

- Ruby 2.0 or higher

## Usage

```ruby
# create new instance, adding your event attributes
cal = AddToCalendar::URLs.new(
        start_datetime: Time.new(2020,12,12,13,30,00,0), 
        title: "Christmas party!", 
        timezone: 'Europe/London'
      )

# access 'add to calendar' URLs
cal.google_url
#=> "https://www.google.com/calendar/render?action=TEMPLATE&text=Christmas%20party%21&dates=20201212T133000/20201212T143000&ctz=Europe/London"

cal.yahoo_url
#=> "https://calendar.yahoo.com/?v=60&view=d&type=20&title=Christmas%20party%21&st=20201212T133000Z&dur=0100"

# ical provided a data-uri which will download a properly formatted *.ics file (more details below)
cal.ical_url
#=> "data:text/calendar;charset=utf8,BEGIN:VCALENDAR%0AVERSION:2.0%0ABEGIN:VEVENT%0ADTSTART=20201212T133000Z%0ADTEND=20201212T143000Z%0ASUMMARY=Christmas%20party%21%0AUID=-20201212T133000Z-Christmas%20party%21%0AEND:VEVENT%0AEND:VCALENDAR"

# apple_url and outlook_url are simply helper methods that call ical_url
cal.apple_url
#=> "data:text/calendar;charset=utf8,BEGIN:VCALENDAR%0AVERSION:2.0%0ABEGIN:VEVENT%0ADTSTART=20201212T133000Z%0ADTEND=20201212T143000Z%0ASUMMARY=Christmas%20party%21%0AUID=-20201212T133000Z-Christmas%20party%21%0AEND:VEVENT%0AEND:VCALENDAR"

cal.outlook_url
#=> "data:text/calendar;charset=utf8,BEGIN:VCALENDAR%0AVERSION:2.0%0ABEGIN:VEVENT%0ADTSTART=20201212T133000Z%0ADTEND=20201212T143000Z%0ASUMMARY=Christmas%20party%21%0AUID=-20201212T133000Z-Christmas%20party%21%0AEND:VEVENT%0AEND:VCALENDAR"
```

### Creating HTML links

```erb
<!-- Simply pass the url into the href Eg. in ERB -->
<a href="<%= cal.google_url %>">Add to Google Calendar</a>

<a href="<%= cal.yahoo_url %>">Add to Yahoo Calendar</a>

<!-- for ical_url, apple_url and outlook_url you can set the filename like so -->
<a download="calendar-event.ics" href="<%= cal.ical_url %>">Download iCal</a>
```

### Event attributes

```ruby
event_attributes = {
    start_datetime: Time.new(2020,12,12,9,00,00,0), # required
    end_datetime: Time.new(2020,12,12,17,00,00,0),
    title: "Ruby Conference", # required
    timezone: 'America/New_York', # required
    location: "20 W 34th St, New York, NY 10001", 
    url: "https://www.ruby-lang.org/en/",
    description: "Join us to learn all about Ruby.",
    add_url_to_description: true # defaults to true
}

cal = AddToCalendar::URLs.new(event_attributes)
```

| Attribute              | Required? | Class      | Notes |
| -----------------------|-----------|------------|-------|
| start_datetime         | Yes       | Time       |       |
| end_datetime           | No        | Time       | <ul><li>If not provided, defaults to start_datetime + 1 hour</li><li>Must be > start_datetime</li></ul> |
| title                  | Yes       | String     |       |
| timezone               | Yes       | String     | Must be in [tz database format](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) Eg. 'Europe/London', 'America/New_York' |
| location               | No        | String     |       |
| url                    | No        | String     | Most providers do not have a native URL field. If you set `url` it will be added to the end of the description field (see `add_url_to_description`) |
| description            | No        | String     | Accepts newlines by passing `\n` Eg. `"Join us for fun & drinks\n\nPS. Smart casual"` |
| add_url_to_description | No        | true/false | defaults to `true`. Set `add_url_to_description: false` to stop the URL from being added to the description |


### Timezones and offsets

- Offset values eg. "2020-05-13 15:31:00 **+05:00**" are ignored. It is only important that you have the correct date and time numbers set. The timezone is set directly using its own attribute `timezone`.
- You must set a timezone so that when users add the event to their calendar it shows at their correct local time. 
  - Eg. London event @ `2020-05-13 13:30:00` will save in a New Yorkers calendar as local time `2020-05-13 17:30:00`

### Browser support

- IE11 and lower will not work for `ical_url`, `apple_url` and `outlook_url` (IE does not properly support [data-uri links](https://caniuse.com/#feat=datauri). See [#16](https://github.com/jaredlt/add_to_calendar/issues/16)). 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaredlt/add_to_calendar.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
