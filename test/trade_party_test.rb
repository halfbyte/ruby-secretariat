require "test_helper"
require "nokogiri"

module Secretariat
  class TradePartyTest < Minitest::Test
    NAMESPACES = {"xmlns:ram" => "urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100"}

    def make_trade_party(**extra)
      attrs = {
        id: "DE304755032",
        name: "Musterfirma",
        street1: "Musterstraße 2",
        city: "Musterstadt",
        postal_code: "20000",
        country_id: "DE",
        vat_id: "DE304755032",
        person_name: "Max Mustermann"
      }.merge(extra)
      TradeParty.new(
        **attrs
      )
    end

    def xml_test_harness(&block)
      Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.RootElement(NAMESPACES) do
          block.call(xml)
        end
      end.to_xml
    end

    def test_render_complete_trade_party_example
      expected_xml = <<~END
        <?xml version="1.0" encoding="UTF-8"?>
        <RootElement xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100">
          <ram:ID>DE304755032</ram:ID>
          <ram:Name>Musterfirma</ram:Name>
          <ram:DefinedTradeContact>
            <ram:PersonName>Moritz Mustermann</ram:PersonName>
            <ram:DepartmentName>Einkauf</ram:DepartmentName>
            <ram:TelephoneUniversalCommunication>
              <ram:CompleteNumber>+491752935345</ram:CompleteNumber>
            </ram:TelephoneUniversalCommunication>
            <ram:EmailURIUniversalCommunication>
              <ram:URIID>mm@example.com</ram:URIID>
            </ram:EmailURIUniversalCommunication>
          </ram:DefinedTradeContact>
          <ram:PostalTradeAddress>
            <ram:PostcodeCode>20000</ram:PostcodeCode>
            <ram:LineOne>Musterstraße 2</ram:LineOne>
            <ram:CityName>Musterstadt</ram:CityName>
            <ram:CountryID>DE</ram:CountryID>
          </ram:PostalTradeAddress>
          <ram:URIUniversalCommunication>
            <ram:URIID schemeID="EM">mm@example.com</ram:URIID>
          </ram:URIUniversalCommunication>
          <ram:SpecifiedTaxRegistration>
            <ram:ID schemeID="VA">DE304755032</ram:ID>
          </ram:SpecifiedTaxRegistration>
        </RootElement>
      END

      tp = make_trade_party(
        electronic_address: "mm@example.com",
        electronic_address_scheme_id: "EM",
        trade_contact: TradeContact.new(
          person_name: "Moritz Mustermann",
          department: "Einkauf",
          telephone: "+491752935345",
          email: "mm@example.com"
        )
      )
      xml = xml_test_harness do |xml|
        tp.to_xml(xml)
      end
      assert_equal expected_xml, xml
    end
  end
end
