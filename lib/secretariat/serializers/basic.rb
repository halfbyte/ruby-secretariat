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
                  xml["ram"].SpecifiedLineTradeAgreement do
                    xml["ram"].NetPriceProductTradePrice do
                      Helpers.currency_element(xml, "ram", "ChargeAmount", line_item.net_amount, line_item.currency_code, add_currency: false, digits: 2)
                    end
                  end
                  xml["ram"].SpecifiedLineTradeDelivery do
                    xml["ram"].BilledQuantity(unitCode: line_item.unit_code) do
                      xml.text(Helpers.format(line_item.billed_quantity, digits: 4))
                    end
                  end
                  xml["ram"].SpecifiedLineTradeSettlement do
                    xml["ram"].ApplicableTradeTax do
                      xml["ram"].TypeCode "VAT"
                      xml["ram"].CategoryCode line_item.tax_category_code(version: 2)
                      unless line_item.untaxable?
                        xml["ram"].RateApplicablePercent Helpers.format(line_item.tax_percent, digits: 2)
                      end
                    end
                    xml["ram"].SpecifiedTradeSettlementLineMonetarySummation do
                      Helpers.currency_element(xml, "ram", "LineTotalAmount", (line_item.billed_quantity.negative? ? -line_item.charge_amount : line_item.charge_amount), line_item.currency_code, add_currency: false)
                    end
                  end
                end
              end
              xml["ram"].ApplicableHeaderTradeAgreement do
                if @invoice.buyer_reference
                  xml["ram"].BuyerReference @invoice.buyer_reference
                end
                xml["ram"].SellerTradeParty do
                  if @invoice.seller.global_id && @invoice.seller.global_id != "" && @invoice.seller.global_id_scheme_id && @invoice.seller.global_id_scheme_id != ""
                    xml["ram"].GlobalID(schemeID: @invoice.seller.global_id_scheme_id) do
                      xml.text(@invoice.seller.global_id)
                    end
                  end
                  xml["ram"].Name @invoice.seller.name
                  xml["ram"].PostalTradeAddress do
                    xml["ram"].PostcodeCode @invoice.seller.postal_code
                    xml["ram"].LineOne @invoice.seller.street1
                    if @invoice.seller.street2 && @invoice.seller.street2 != ""
                      xml["ram"].LineTwo @invoice.seller.street2
                    end
                    xml["ram"].CityName @invoice.seller.city
                    xml["ram"].CountryID @invoice.seller.country_id
                  end
                  if @invoice.seller.tax_id && @invoice.seller.tax_id != ""
                    xml["ram"].SpecifiedTaxRegistration do
                      xml["ram"].ID(schemeID: "FC") do
                        xml.text(@invoice.seller.tax_id)
                      end
                    end
                  end
                  if @invoice.seller.vat_id && @invoice.seller.vat_id != ""
                    xml["ram"].SpecifiedTaxRegistration do
                      xml["ram"].ID(schemeID: "VA") do
                        xml.text(@invoice.seller.vat_id)
                      end
                    end
                  end
                end
                xml["ram"].BuyerTradeParty do
                  if @invoice.buyer.global_id && @invoice.buyer.global_id != "" && @invoice.buyer.global_id_scheme_id && @invoice.buyer.global_id_scheme_id != ""
                    xml["ram"].GlobalID(schemeID: @invoice.buyer.global_id_scheme_id) do
                      xml.text(@invoice.buyer.global_id)
                    end
                  end
                  xml["ram"].Name @invoice.buyer.name
                  xml["ram"].PostalTradeAddress do
                    xml["ram"].PostcodeCode @invoice.buyer.postal_code
                    xml["ram"].LineOne @invoice.buyer.street1
                    if @invoice.buyer.street2 && @invoice.buyer.street2 != ""
                      xml["ram"].LineTwo @invoice.buyer.street2
                    end
                    xml["ram"].CityName @invoice.buyer.city
                    xml["ram"].CountryID @invoice.buyer.country_id
                  end
                  if @invoice.buyer.vat_id && @invoice.buyer.vat_id != ""
                    xml["ram"].SpecifiedTaxRegistration do
                      xml["ram"].ID(schemeID: "VA") do
                        xml.text(@invoice.buyer.vat_id)
                      end
                    end
                  end
                  if @invoice.buyer.tax_id && @invoice.buyer.tax_id != ""
                    xml["ram"].SpecifiedTaxRegistration do
                      xml["ram"].ID(schemeID: "FC") do
                        xml.text(@invoice.buyer.tax_id)
                      end
                    end
                  end
                end
              end
              xml["ram"].ApplicableHeaderTradeDelivery do
                xml["ram"].ActualDeliverySupplyChainEvent do
                  xml["ram"].OccurrenceDateTime do
                    xml["udt"].DateTimeString(format: "102") do
                      xml.text(@invoice.issue_date.strftime("%Y%m%d"))
                    end
                  end
                end
              end
              xml["ram"].ApplicableHeaderTradeSettlement do
                xml["ram"].InvoiceCurrencyCode @invoice.currency_code
                @invoice.taxes.each do |tax|
                  xml["ram"].ApplicableTradeTax do
                    Helpers.currency_element(xml, "ram", "CalculatedAmount", tax.tax_amount, @invoice.currency_code, add_currency: false)
                    xml["ram"].TypeCode "VAT"
                    if @invoice.tax_reason_text(tax) && @invoice.tax_reason_text(tax) != ""
                      xml["ram"].ExemptionReason @invoice.tax_reason_text(tax)
                    end
                    Helpers.currency_element(xml, "ram", "BasisAmount", tax.base_amount, @invoice.currency_code, add_currency: false)
                    xml["ram"].CategoryCode @invoice.tax_category_code(tax, version: 2)
                    xml["ram"].RateApplicablePercent Helpers.format(tax.tax_percent)
                  end
                end
                xml["ram"].SpecifiedTradePaymentTerms do
                  if @invoice.payment_terms_text
                    xml["ram"].Description @invoice.payment_terms_text || "Paid"
                  end
                  if @invoice.payment_due_date
                    xml["ram"].DueDateDateTime do
                      Helpers.date_element(xml, @invoice.payment_due_date)
                    end
                  end
                end
                xml["ram"].SpecifiedTradeSettlementHeaderMonetarySummation do
                  Helpers.currency_element(xml, "ram", "LineTotalAmount", @invoice.basis_amount, @invoice.currency_code, add_currency: false)
                  Helpers.currency_element(xml, "ram", "ChargeTotalAmount", BigDecimal(0), @invoice.currency_code, add_currency: false)
                  Helpers.currency_element(xml, "ram", "AllowanceTotalAmount", BigDecimal(0), @invoice.currency_code, add_currency: false)
                  Helpers.currency_element(xml, "ram", "TaxBasisTotalAmount", @invoice.basis_amount, @invoice.currency_code, add_currency: false)
                  Helpers.currency_element(xml, "ram", "TaxTotalAmount", @invoice.tax_amount, @invoice.currency_code, add_currency: true)
                  Helpers.currency_element(xml, "ram", "GrandTotalAmount", @invoice.grand_total_amount, @invoice.currency_code, add_currency: false)
                  if @invoice.paid_amount > 0
                    Helpers.currency_element(xml, "ram", "TotalPrepaidAmount", @invoice.paid_amount, @invoice.currency_code, add_currency: false)
                  end
                  Helpers.currency_element(xml, "ram", "DuePayableAmount", @invoice.due_amount, @invoice.currency_code, add_currency: false)
                end
              end
              if Array(@invoice.attachments).size > 0
                @invoice.attachments.each_with_index do |attachment, index|
                  @invoice.attachment.to_xml(xml, index, version: 2)
                end
              end
            end
          end
        end.to_xml
      end
    end
  end
end
