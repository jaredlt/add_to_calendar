lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "add_to_calendar/version"

Gem::Specification.new do |spec|
  spec.name          = "add_to_calendar"
  spec.version       = AddToCalendar::VERSION
  spec.authors       = ["Jared Turner", "James Watling"]
  spec.email         = ["jaredlt01@gmail.com", "watling.james@gmail.com"]

  spec.summary       = "Generate 'Add To Calendar' URLs for Android, Apple, Google, Office 365, Outlook, Outlook.com and Yahoo calendars"
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/jaredlt/add_to_calendar"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.add_dependency "tzinfo", ">= 1.1", "< 3"
  spec.add_dependency "tzinfo-data", "~> 1.2021"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0.3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry", "~> 0.14.0"
end
