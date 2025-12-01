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
  using ObjectExtensions
  
  TradeParty = Struct.new('TradeParty',
    :id,
    :name, :street1, :street2, :city, :postal_code, :country_id, :vat_id, :global_id, :global_id_scheme_id, :tax_id,
    keyword_init: true,
  ) do
    def to_xml(xml, exclude_tax: false, version: 2)
      if id
        xml['ram'].ID id # BT-46
      end
      if global_id.present? && global_id_scheme_id.present?
        xml['ram'].GlobalID(schemeID: global_id_scheme_id) do
          xml.text(global_id)
        end
      end
      xml['ram'].Name name
      xml['ram'].PostalTradeAddress do
        xml['ram'].PostcodeCode postal_code
        xml['ram'].LineOne street1
        if street2.present?
          xml['ram'].LineTwo street2
        end
        xml['ram'].CityName city
        xml['ram'].CountryID country_id
      end
      if !exclude_tax && vat_id.present?
        xml['ram'].SpecifiedTaxRegistration do
          xml['ram'].ID(schemeID: 'VA') do
            xml.text(vat_id)
          end
        end
      elsif tax_id.present?
        xml['ram'].SpecifiedTaxRegistration do
          xml['ram'].ID(schemeID: 'FC') do
            xml.text(tax_id)
          end
        end
      end
    end
  end
end
