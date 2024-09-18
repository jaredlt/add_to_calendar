$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "add_to_calendar"
require "minitest/autorun"
require "timecop"
require "pry"

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |file| require file }
