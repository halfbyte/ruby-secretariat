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
    attr_accessor :doc
    def initialize(io_or_str)
      @doc = Nokogiri.XML(io_or_str)
    end

    def schema
      Nokogiri::XML.Schema open(File.join(__dir__, '../../schemas/zf_en16931.xsd'))
    end

    def schematron
      SchematronNokogiri::Schema.new(
        Nokogiri::XML(open(File.join(__dir__, '../../schemas/zf_en16931.sch')))
      )
    end

    def validate_against_schema
      schema.validate(doc)
    end

    def validate_against_schematron
      result = []
      Dir.chdir File.join(__dir__, '../../schemas') do
        result = schematron.validate(doc)
      end
      result
    end
  end
end
