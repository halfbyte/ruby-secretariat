module Secretariat
  module Serializers
    class Basic
      NAMESPACES = {
        'xmlns:qdt' => "urn:un:unece:uncefact:data:standard:QualifiedDataType:100",
        "xmlns:ram" => "urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100",
        "xmlns:udt" => "urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100",
        "xmlns:rsm" => "urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance"
      }

      attr_reader :invoice

      def initialize(invoice)
        @invoice = invoice
      end

      def profile_id
        "urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic"
      end

      def type_code
        '380'
      end

      def serialize
        Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml['rsm'].CrossIndustryInvoice(NAMESPACES) do
            xml['rsm'].ExchangedDocumentContext do
              xml['ram'].GuidelineSpecifiedDocumentContextParameter do
                xml['ram'].ID profile_id
              end
            end
            xml['rsm'].ExchangedDocument do
              xml['ram'].ID invoice.id
              xml['ram'].TypeCode type_code # TODO: make configurable
              xml['ram'].IssueDateTime do
                xml['udt'].DateTimeString(format: '102') do
                  xml.text(invoice.issue_date.strftime("%Y%m%d"))
                end
              end
            end
            xml['rsm'].SupplyChainTradeTransaction do

            end
          end
        end.to_xml
      end

    end
  end
end
