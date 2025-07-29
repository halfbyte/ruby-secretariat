require_relative '../lib/secretariat.rb'
require 'minitest/autorun'
require 'nokogiri/diff'


class Minitest::Test
  def assert_equal_xml(original, test_object)
    original_xml = Nokogiri::XML(original)
    test_object_xml = Nokogiri::XML(test_object)
    diff = original_xml.diff(test_object_xml)
    diff.each do |c, n|
      assert_equal " ", c

    end
  end
end