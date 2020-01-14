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
require 'schematron-nokogiri'
require 'open-uri'

module Secretariat
  class Validator
    SCHEMATRON = [
      '../../schemas/zugferd_1/ZUGFeRD1p0.sch',
      '../../schemas/zugferd_2/zf_en16931.sch'
    ]

    SCHEMA = [
      '../../schemas/zugferd_1/ZUGFeRD1p0.xsd',
      '../../schemas/zugferd_2/zf_en16931.xsd'
    ]

    SCHEMA_DIR = [
      '../../schemas/zugferd_1',
      '../../schemas/zugferd_2'
    ]
    attr_accessor :doc, :version
    def initialize(io_or_str, version: 1)
      @doc = Nokogiri.XML(io_or_str)
      @version = version
    end

    def schema
      Nokogiri::XML.Schema open(File.join(__dir__, SCHEMA[version - 1]))
    end

    def schematron
      SchematronNokogiri::Schema.new(
        Nokogiri::XML(open(File.join(__dir__, SCHEMATRON[version - 1])))
      )
    end

    def validate_against_schema
      schema.validate(doc)
    end

    def validate_against_schematron
      result = []
      Dir.chdir File.join(__dir__, SCHEMA_DIR[version - 1]) do
        result = schematron.validate(doc)
      end
      result
    end
  end
end
