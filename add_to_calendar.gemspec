lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "add_to_calendar/version"

Gem::Specification.new do |spec|
  spec.name          = "add_to_calendar"
  spec.version       = AddToCalendar::VERSION
  spec.authors       = ["Jared Turner"]
  spec.email         = ["jaredlt01@gmail.com"]

  spec.summary       = "Generate 'Add To Calendar' URLs for Google, Apple, Office 365, Outlook, Yahoo calendars"
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

  spec.add_dependency "tzinfo", "~> 2.0.2"
  spec.add_dependency "tzinfo-data", "~> 1.2020.1"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry", "~> 0.13.1"
end
