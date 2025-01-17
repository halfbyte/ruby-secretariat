=begin
Copyright Jan Krutisch and contributors (see CONTRIBUTORS.md)

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

module Secretariat
  TradeParty = Struct.new('TradeParty',
    :name, :street1, :street2, :city, :postal_code, :country_id, :vat_id,
    keyword_init: true,
  ) do
    def to_xml(xml, exclude_tax: false, version: 2)
      xml['ram'].Name name
      xml['ram'].PostalTradeAddress do
        xml['ram'].PostcodeCode postal_code
        xml['ram'].LineOne street1
        if street2 && street2 != ''
          xml['ram'].LineTwo street2
        end
        xml['ram'].CityName city
        xml['ram'].CountryID country_id
      end
      if !exclude_tax && vat_id && vat_id != ''
        xml['ram'].SpecifiedTaxRegistration do
          xml['ram'].ID(schemeID: 'VA') do
            xml.text(vat_id)
          end
        end
      end
    end
  end


end
