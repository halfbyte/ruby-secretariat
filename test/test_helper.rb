require_relative "../lib/secretariat"
require "minitest/autorun"
require "nokogiri/diff"

class Minitest::Test
  def read_fixture(path)
    File.read(File.join(__dir__, "fixtures", path))
  end

  def assert_equal_xml(original, test_object, message = "")
    original_xml = Nokogiri::XML(original) do |config|
      config.strict.noblanks
    end
    test_object_xml = Nokogiri::XML(test_object) do |config|
      config.strict.noblanks
    end

    diff = original_xml.diff(test_object_xml)

    pp diff

    diff = diff.reject do |c, n|
      n.is_a?(Nokogiri::XML::Comment)
    end

    has_differences = diff.reject { |c, n| c == " " }.any? # standard:disable Style/HashExcept

    formatted = diff.map do |change, node|
      if change != " " && node.is_a?(Nokogiri::XML::Text) || node.is_a?(Nokogiri::XML::Attr)
        change + " #{node.to_s.tr(" ", ".")}".ljust(20) + " " + node.path
      else
        change + " ".ljust(20) + node.path
      end
    end
    assert !has_differences, "XML differs:\n #{formatted.join("\n")}"
  end
end
