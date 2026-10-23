require_relative "../lib/secretariat"
require "minitest/autorun"

module Secretariat
  module TestExtensions
    ##
    # Assertion to check xml against the schema files
    # To allow for easy removal of V1, version 2 is assumed
    # +xml+ is the generated xml as a string, +version:+ allows to specifiy version 1 if needed

    def assert_valid_schema(xml, version: 2)
      errors = Validator.new(xml, version: version).validate_against_schema
      if !errors.empty? && ENV["OUTPUT_XML_ON_ERROR"]
        puts xml
      end
      assert_empty errors, errors.join("\n")
    end

    ##
    # Assertion to check xml against the schematron files
    # This assertion requires and assumes Java installed so that schxslt-cli.jar can be used
    # To allow for easy removal of V1, version 2 is assumed
    # +xml+ is the generated xml as a string, +version:+ allows to specifiy version 1 if needed
    def assert_valid_schematron(xml, version: 2)
      errors = Validator.new(xml, version: version).validate_against_schematron
      if !errors.empty? && ENV["OUTPUT_XML_ON_ERROR"]
        puts xml
      end
      assert_empty errors, errors.join("\n")
    end
  end

  class Test < Minitest::Test
    include TestExtensions
  end
end
