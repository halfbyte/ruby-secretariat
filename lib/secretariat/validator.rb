=begin
Copyright Jan Krutisch

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

require 'nokogiri'
require 'tmpdir'

module Secretariat

  class ValidatorError < StandardError; end


  class Validator
    SCHEMATRON = [
      '../../schemas/zugferd_1/ZUGFeRD1p0.sch',
      '../../schemas/factur-x_1.0.0.7/Factur-X_1.0.07_EN16931.sch'
    ]

    SCHEMA = [
      '../../schemas/zugferd_1/ZUGFeRD1p0.xsd',
      '../../schemas/factur-x_1.0.0.7/Factur-X_1.0.07_EN16931.xsd'
    ]

    SCHEMA_DIR = [
      '../../schemas/zugferd_1',
      '../../schemas/factur-x_1.0.0.7/'
    ]

    attr_accessor :doc, :version
    def initialize(io_or_str, version: 1)
      @doc = Nokogiri.XML(io_or_str)
      @version = version
    end

    def schema
      Nokogiri::XML.Schema open(File.join(__dir__, SCHEMA[version - 1]))
    end

    def schematron_path
      File.join(__dir__, SCHEMATRON[version - 1])
    end

    def validate_against_schema
      schema.validate(doc)
    end

    def validate_against_schematron
      Dir.mktmpdir do |dir|
        docpath = File.join(dir, 'doc.xml')
        File.write(docpath, doc, mode: 'wb')
        jarpath = File.join(__dir__, '../..', 'bin', 'schxslt-cli.jar')
        out = `java -jar #{jarpath} -v -d #{docpath} -s #{schematron_path}`
        return [] if out.start_with?("[valid]")
        return process_schematron_errors(out)
      end
    end

    private

    def process_schematron_errors(output)
      errors = []
      error_lines = output.lines.clone
      error_lines.shift # get rid of file notice
      
      while(error_lines.length > 0) do
        assert_error = error_lines.shift
        _, ref = assert_error.split(" failed-assert ").map(&:strip)
        error_description = error_lines.shift.strip
        errors << ValidatorError.new("#{error_description} - Reference: #{ref}")
      end
      errors
    end
  end
end
