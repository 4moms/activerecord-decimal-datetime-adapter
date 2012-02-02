# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "activerecord-decimal-datetime-adapter/version"

Gem::Specification.new do |s|
  s.name        = "activerecord-decimal-datetime-adapter"
  s.version     = Activerecord::Decimal::Datetime::Adapter::VERSION
  s.authors     = ["Benjamin R. Haskell"]
  s.email       = ["bhaskell@4moms.com"]
  s.homepage    = ""
  s.summary     = %q{Deal with dates and times stored as decimals}
  s.description = <<DESCRIPTION
The Accpac database uses DECIMAL as the data type for date and time fields.
Presumably this was to gloss over differences in database drivers in their
handling of date- and time-related fields.
DESCRIPTION

  #s.rubyforge_project = "activerecord-decimal-datetime-adapter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
