# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hstore_translations/version'

Gem::Specification.new do |s|
  s.name          = "hstore_translations"
  s.version       = HstoreTranslations::VERSION
  s.authors       = ["Aleksey Demidov"]
  s.email         = ["aleksey.dem@gmail.com"]
  s.summary       = 'Translations for Rails 4 model columns, stored in hstore'
  s.homepage      = ""
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency "activerecord", ">= 4.0"

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
