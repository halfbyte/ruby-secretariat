require 'test_helper'


module Secretariat
  class ValidatorTest < Minitest::Test
    def test_schema_validator
      xml = open(File.join(__dir__, 'fixtures/extended.xml'))
      v = Validator.new(xml)
      assert_equal [], v.validate_against_schema
    end

    def test_schematron_validator
      xml = open(File.join(__dir__, 'fixtures/extended.xml'))
      v = Validator.new(xml)
      assert_equal [], v.validate_against_schematron
    end
  end
end

