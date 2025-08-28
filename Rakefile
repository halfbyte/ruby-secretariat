require "rake/testtask"
require "standard/rake"

Rake::TestTask.new do |t|
  t.libs = ["lib", "test"]
  t.pattern = "test/**/*_test.rb"
end

task default: [:standard, :test]
