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


require 'mime/types'

module Secretariat
  Attachment = Struct.new('Attachment',
    :filename,
    :type_code,
    :base64,

    keyword_init: true
  ) do
    include Versioner

    def errors
      @errors
    end

    def valid?
      @errors = []

      @errors << "the attribute filename needs to be present" if filename.nil? || filename == ''
      @errors << "the attribute type_code needs to be present" if type_code.nil? || type_code == ''
      @errors << "the attribute base64 needs to be present" if base64.nil? || base64 == ''

      if type_code.to_i != 916
        @errors << "we only support type_code 916"
        return false
      end

      if mime_code.nil?
        @errors << "cannot determine content type for filename: #{filename}"
        return false
      end
      
      if !ALLOWED_MIME_TYPES.include?(mime_code)
        @errors << "the mime_code '#{mime_code}' is not allowed"
        return false
      end

      return true
    end

    def mime_code
      type_for = MIME::Types.type_for(filename).first
      return if type_for.nil?

      type_for.content_type
    end

    def to_xml(xml, attachment_index, version: 2, validate: true)
      if validate && !valid?
        pp errors
        raise ValidationError.new("Attachment #{attachment_index} is invalid", errors)
      end

      xml['ram'].AdditionalReferencedDocument do
        xml['ram'].IssuerAssignedID filename
        xml['ram'].TypeCode type_code
        xml['ram'].Name filename
        xml['ram'].AttachmentBinaryObject(mimeCode: mime_code, filename: filename) do
          xml.text(base64)
        end
      end
    end
  end
end
