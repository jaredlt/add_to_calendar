# AddToCalendar

A ruby gem to generate 'Add To Calendar' URLs for Android, Apple, Google, Hey, Office 365, Outlook, Outlook.com and Yahoo calendars.

If this gem brings you some value feel free to buy me a coffee :) [![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/P5P71PK9T)

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
@cal = AddToCalendar::URLs.new(
        start_datetime: Time.new(2020,12,12,13,30,00,0), 
        title: "Christmas party!", 
        timezone: 'Europe/London'
      )

# access 'add to calendar' URLs
@cal.google_url
#=> "https://www.google.com/calendar/render?action=TEMPLATE&text=Christmas%20party%21&dates=20201212T133000/20201212T143000&ctz=Europe/London"

@cal.yahoo_url
#=> "https://calendar.yahoo.com/?v=60&view=d&type=20&title=Christmas%20party%21&st=20201212T133000Z&dur=0100"

@cal.hey_url
#=> "https://app.hey.com/calendar/ical_events/new?ical_source=BEGIN%3AVCALENDAR%0AVERSION%3A2.0%0APRODID%3A-//AddToCalendar//RubyGem//EN%0ABEGIN%3AVEVENT%0ASUMMARY%3AHolly%27s%209th%20birthday%21%0ADTSTAMP%3A20240913T151029Z%0ADTSTART%3A20240906T123000Z%0ADTEND%3A20240906T133000Z%0AUID%3A-20240906T123000Z-Holly%27s%209th%20birthday%21%0AEND%3AVEVENT%0AEND%3AVCALENDAR"

@cal.office365_url
#=> "https://outlook.office.com/calendar/0/action/compose?rru=addevent&subject=Christmas%20party%21&startdt=2020-12-12T13:30:00Z&enddt=2020-12-12T14:30:00Z"

# For outlook.com, different to Outlook the desktop application below
@cal.outlook_com_url
#=> "https://outlook.live.com/calendar/0/action/compose?rru=addevent&subject=Christmas%20party%21&startdt=2020-12-12T13:30:00Z&enddt=2020-12-12T14:30:00Z"

# ical provides a data-uri which will download a properly formatted *.ics file (see 'Creating HTML links' section)
@cal.ical_url
#=> "data:text/calendar;charset=utf8,BEGIN:VCALENDAR%0AVERSION:2.0%0ABEGIN:VEVENT%0ADTSTART:20201212T133000Z%0ADTEND:20201212T143000Z%0ASUMMARY:Christmas%20party%21%0AUID:-20201212T133000Z-Christmas%20party%21%0AEND:VEVENT%0AEND:VCALENDAR"

# android_url, apple_url and outlook_url are simply helper methods that call ical_url and return the same string.
```

### Creating HTML links

```erb
<!-- Simply pass the url into the href Eg. in ERB -->
<a href="<%= @cal.google_url %>">Add to Google Calendar</a>

<a href="<%= @cal.yahoo_url %>">Add to Yahoo Calendar</a>

<!-- for ical_url, android_url, apple_url and outlook_url you can set the filename like so -->
<a download="calendar-event.ics" href="<%= @cal.ical_url %>">Download iCal</a>
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
    add_url_to_description: true, # defaults to true
    all_day: true, # defaults to false
    organizer: { 
      name: "First Last",
      email: "email@example.com"
    }
}

cal = AddToCalendar::URLs.new(**event_attributes)
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
| add_url_to_description | No        | true/false | Defaults to `true`. Set `add_url_to_description: false` to stop the URL from being added to the description |
| all_day                | No        | true/false | <ul><li>Defaults to `false`.</li><li>When set to `true` the times will be ignored.</li><li>If no end_datetime provided it will be a single day event.</li><li>When providing end_datetime, use the final day of the event (eg. 1 day event start: 2023-05-01, end: 2023-05-01; 3 day event start: 2023-05-01, end: 2023-05-03).</li><li>Some calendars require you to specify the _day after_ as the end date which feels counterintuitive, this Gem takes care of that for you.</li></ul> |
| organizer              | No        | Hash | <ul><li>Only supported by ical</li><li>If used you must provide both `name` and `email`</li><li>Must be in format `{ name: "First Last", email: "email@example.com" }`</li></ul> |

### Timezones and offsets

- Offset values eg. "2020-05-13 15:31:00 **+05:00**" are ignored. It is only important that you have the correct date and time numbers set. The timezone is set directly using its own attribute `timezone`.
- You must set a timezone so that when users add the event to their calendar it shows at their correct local time. 
  - Eg. London event @ `2020-05-13 13:30:00` will save in a New Yorker's calendar as local time `2020-05-13 17:30:00`

### Browser support

- IE11 and lower will not work for `ical_url`, `apple_url` and `outlook_url` (IE does not properly support [data-uri links](https://caniuse.com/#feat=datauri). See [#16](https://github.com/jaredlt/add_to_calendar/issues/16)).
- IE11 will also not work with `Yahoo`, but this is because Yahoo  is deprecating IE 11 support and only offers a simplified interface which does not work with the add event URL.

### More details

- Read the [Wiki](https://github.com/jaredlt/add_to_calendar/wiki) for more specific details

## Why build this?

I couldn't find an approriate gem or javascript library that did exactly what I wanted. So I decided to scratch my own itch to solve a problem for a startup I'm working on: https://www.littlefutures.org

## Releases

- https://rubygems.org/gems/add_to_calendar

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaredlt/add_to_calendar.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
