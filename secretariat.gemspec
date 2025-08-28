require_relative "lib/secretariat/version"

# Rolling my own file_list to not have to rely on rake
# as this breaks ruby-setup on GitHub actions
# This should be good enough for now, even though
# FileList does a lot more.
def self.file_list(*patterns)
  patterns.map do |pattern|
    Dir.glob(pattern)
  end.flatten.reject do |file|
    File.basename(file).start_with?(".")
  end
end

Gem::Specification.new do |s|
  s.name = "secretariat"
  s.version = Secretariat::VERSION
  s.summary = "A ZUGFeRD xml generator"
  s.description = "a tool to help generate and validate ZUGFeRD invoice xml files"
  s.authors = ["Jan Krutisch"]
  s.email = "jan@krutisch.de"
  s.files = file_list("lib/**/*.rb", "bin/*.jar", "schemas/**/*", "README.md")
  s.homepage = "https://github.com/halfbyte/ruby-secretariat"
  s.license = "Apache-2.0"

  s.required_ruby_version = ">= 2.6.0"

  s.add_runtime_dependency "nokogiri", "~> 1.10"
  s.add_runtime_dependency "bigdecimal", "~> 3.1"
  s.add_runtime_dependency "mime-types", "~> 3.6"

  s.add_development_dependency "minitest", "~> 5.13"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "base64", "~> 0.3.0"
  s.add_development_dependency "nokogiri-diff", "~> 0.3.0"
  s.add_development_dependency "standard", "~> 1.50"
  s.requirements << "To run the validator, Java must be installed"
end
