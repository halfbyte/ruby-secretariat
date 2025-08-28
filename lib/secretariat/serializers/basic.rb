module Secretariat
  module Serializers
    class Basic
      NAMESPACES = {
        "xmlns:qdt" => "urn:un:unece:uncefact:data:standard:QualifiedDataType:100",
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
        "380"
      end

      def serialize
        Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml["rsm"].CrossIndustryInvoice(NAMESPACES) do
            xml["rsm"].ExchangedDocumentContext do
              xml["ram"].GuidelineSpecifiedDocumentContextParameter do
                xml["ram"].ID profile_id
              end
            end
            xml["rsm"].ExchangedDocument do
              xml["ram"].ID invoice.id
              xml["ram"].TypeCode type_code # TODO: make configurable
              xml["ram"].IssueDateTime do
                xml["udt"].DateTimeString(format: "102") do
                  xml.text(invoice.issue_date.strftime("%Y%m%d"))
                end
              end
              Array(@invoice.notes).each do |note|
                xml["ram"].IncludedNote do
                  xml["ram"].Content note
                end
              end
            end
            xml["rsm"].SupplyChainTradeTransaction do
              @invoice.line_items.each_with_index do |line_item, i|
                xml["ram"].IncludedSupplyChainTradeLineItem do
                  xml["ram"].AssociatedDocumentLineDocument do
                    xml["ram"].LineID i + 1
                  end
                  xml["ram"].SpecifiedTradeProduct do
                    if line_item.global_id
                      xml["ram"].GlobalID(schemeID: line_item.global_id_scheme_id) do
                        xml.text line_item.global_id
                      end
                    end
                    xml["ram"].Name line_item.name
                    if line_item.origin_country_code
                      xml["ram"].OriginTradeCountry do
                        xml["ram"].ID origin_country_code
                      end
                    end
                  end
                end
              end
            end
          end
        end.to_xml
      end
    end
  end
end
