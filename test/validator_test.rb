require 'test_helper'


module Secretariat
  class ValidatorTest < Minitest::Test
    def test_schema_validator_2
      xml = open(File.join(__dir__, 'fixtures/factur-x_1.0.0.7/factur-x.xml'))
      v = Validator.new(xml, version: 2)
      assert_equal [], v.validate_against_schema
    end

    def test_schematron_validator_2
      xml = open(File.join(__dir__, 'fixtures/factur-x_1.0.0.7/factur-x.xml'))
      v = Validator.new(xml, version: 2)
      assert_equal [], v.validate_against_schematron
    end

    def test_invalid_schematron_validator_2
      xml = open(File.join(__dir__, 'fixtures/factur-x_1.0.0.7/invalid.xml'))
      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schematron
      assert_equal 2, errors.length
      assert_match(/\[BR-29\]/, errors.first.message)
      assert_match(/Value of '@format' is not allowed/, errors[1].message)
    end

    def test_schema_validator_1
      xml = open(File.join(__dir__, 'fixtures/zugferd_1/einfach.xml'))
      v = Validator.new(xml, version: 1)
      assert_equal [], v.validate_against_schema
    end

    def test_schematron_validator_1
      xml = open(File.join(__dir__, 'fixtures/zugferd_1/einfach.xml'))
      v = Validator.new(xml, version: 1)
      assert_equal [], v.validate_against_schematron
    end

    def test_invalid_schematron_validator_1
      xml = open(File.join(__dir__, 'fixtures/zugferd_1/invalid.xml'))
      v = Validator.new(xml, version: 1)
      errors = v.validate_against_schematron
      assert_equal 1, errors.length
      assert_match(/Element 'ram:BasisAmount' must occur exactly 1 times/, errors.first.message)
    end
  end
end

