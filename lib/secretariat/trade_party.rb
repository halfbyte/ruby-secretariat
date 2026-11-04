# Copyright Jan Krutisch and contributors (see CONTRIBUTORS.md)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Secretariat
  using ObjectExtensions

  ##
  # if trade_contact is given, person_name is ignored, person_name is just left
  # for keeping the API backwards compatible
  TradeParty = Struct.new("TradeParty",
    :id,
    :name, :street1, :street2, :city, :postal_code, :country_id, :vat_id, :global_id, :global_id_scheme_id, :tax_id,
    :person_name, :legal_organization,
    :electronic_address, :electronic_address_scheme_id,
    :trade_contact,
    keyword_init: true) do
    ##
    # To be able to reusable for delivery contacts, including tax data, the
    # TradeContact fields and the electronic_address fields can be disabled.
    def to_xml(xml, exclude_tax: false, exclude_contact: false, exclude_electronic_address: false, version: 2)
      if id && !exclude_tax
        xml["ram"].ID id # BT-46
      end
      if global_id.present? && global_id_scheme_id.present?
        xml["ram"].GlobalID(schemeID: global_id_scheme_id) do
          xml.text(global_id)
        end
      end
      xml["ram"].Name name
      if legal_organization.present?
        xml["ram"].SpecifiedLegalOrganization do
          xml["ram"].ID(schemeID: legal_organization[:scheme_id] || "0002") do
            xml.text(legal_organization[:id])
          end
        end
      end
      if !exclude_contact
        if trade_contact.present?
          trade_contact.to_xml(xml, version: version)
        elsif person_name.present?
          xml["ram"].DefinedTradeContact do
            xml["ram"].PersonName person_name
          end
        end
      end
      xml["ram"].PostalTradeAddress do
        xml["ram"].PostcodeCode postal_code
        xml["ram"].LineOne street1
        if street2.present?
          xml["ram"].LineTwo street2
        end
        xml["ram"].CityName city
        xml["ram"].CountryID country_id
      end
      # EN16931 BT-34 / BT-49, the scheme (BT-34-1 / BT-49-1) is mandatory (BR-62, BR-63).
      # Like the ID, it is left out of the ShipToTradeParty, where it is not used.
      if version == 2 && !exclude_electronic_address && electronic_address.present? && electronic_address_scheme_id.present?
        xml["ram"].URIUniversalCommunication do
          xml["ram"].URIID(schemeID: electronic_address_scheme_id) do
            xml.text(electronic_address)
          end
        end
      end
      if !exclude_tax && vat_id.present?
        xml["ram"].SpecifiedTaxRegistration do
          xml["ram"].ID(schemeID: "VA") do
            xml.text(vat_id)
          end
        end
      elsif tax_id.present?
        xml["ram"].SpecifiedTaxRegistration do
          xml["ram"].ID(schemeID: "FC") do
            xml.text(tax_id)
          end
        end
      end
    end
  end
end

# assert_match(%r{<ram:DefinedTradeContact>\s*<ram:PersonName>Max Mustermann</ram:PersonName>\s*</ram:DefinedTradeContact>}, xml)
