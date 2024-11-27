require_relative 'lib/secretariat/version'
#require 'rake'
Gem::Specification.new do |s|
  s.name        = 'secretariat'
  s.version     = Secretariat::VERSION
  s.date        = '2024-11-06'
  s.summary     = "A ZUGFeRD xml generator"
  s.description = "a tool to help generate and validate ZUGFeRD invoice xml files"
  s.authors     = ["Jan Krutisch"]
  s.email       = 'jan@krutisch.de'
  
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.homepage    = 'https://github.com/halfbyte/ruby-secretariat'
  s.license       = 'Apache-2.0'

  s.required_ruby_version = '>= 2.6.0'

  s.add_runtime_dependency 'nokogiri', '~> 1.10'
  s.add_runtime_dependency 'bigdecimal', '~> 3.1'

  s.add_development_dependency 'minitest', '~> 5.13'
  s.add_development_dependency 'rake', '~> 13.0'
  s.requirements << "To run the validator, Java must be installed"
end
