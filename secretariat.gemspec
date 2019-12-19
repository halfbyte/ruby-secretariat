require_relative 'lib/secretariat/version'
require 'rake'
Gem::Specification.new do |s|
  s.name        = 'secretariat'
  s.version     = Secretariat::VERSION
  s.date        = '2019-12-19'
  s.summary     = "A ZUGFeRD xml generator"
  s.description = "a tool to help generate and validate ZUGFeRD invoice xml files"
  s.authors     = ["Jan Krutisch"]
  s.email       = 'jan@krutisch.de'
  s.files       = FileList['lib/**/*.rb', 'schemas/*', 'README.md']
  s.homepage    = 'https://github.com/halfbyte/secretariat'
  s.license       = 'Apache-2.0'

  s.add_runtime_dependency 'nokogiri', '~> 1.10'
  s.add_runtime_dependency 'schematron-nokogiri', '~> 0.0', '>= 0.0.3'

  s.add_development_dependency 'minitest', '~> 5.13'
  s.add_development_dependency 'rake', '~> 13.0'
end
