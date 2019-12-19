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

require 'bigdecimal'

module Secretariat
  Invoice = Struct.new("Invoice",
    :id,
    :issue_date,
    :seller,
    :buyer,
    :line_items,
    :currency_code,
    :payment_type,
    :payment_text,
    :tax_category,
    :tax_percent,
    :tax_amount,
    :tax_reason,
    :basis_amount,
    :grand_total_amount,
    :due_amount,
    :paid_amount,

    keyword_init: true
  ) do

    def errors
      @errors
    end

    def tax_reason_text
      tax_reason || TAX_EXEMPTION_REASONS[tax_category]
    end

    def tax_category_code
      TAX_CATEGORY_CODES[tax_category] || 'S'
    end

    def payment_code
      PAYMENT_CODES[payment_type] || '1'
    end

    def valid?
      @errors = []
      tax = BigDecimal(tax_amount)
      basis = BigDecimal(basis_amount)
      calc_tax = basis * BigDecimal(tax_percent) / BigDecimal(100)
      if tax != calc_tax
        @errors << "Tax amount and calculated tax amount deviate"
        return false
      end
      grand_total = BigDecimal(grand_total_amount)
      calc_grand_total = basis + tax
      if grand_total != calc_grand_total
        @errors << "Grand total amount and calculated grand total amount deviate"
        return false
      end
      line_item_sum = line_items.inject(BigDecimal(0)) do |m, item|
        m + BigDecimal(item.charge_amount)
      end
      if line_item_sum != basis
        @errors << "Line items do not add up to basis amount"
        return false
      end
      return true
    end


    def to_xml()

      unless valid?
        raise ValidationError.new("Invoice is invalid", errors)
      end

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.CrossIndustryInvoice({
          'xmlns:qdt' => 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100',
          'xmlns:ram' => 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100',
          'xmlns:udt' => 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100',
          'xmlns' => 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
        }) do
          xml.ExchangedDocumentContext do
            xml['ram'].GuidelineSpecifiedDocumentContextParameter do
              xml['ram'].ID 'urn:cen.eu:en16931:2017'
            end
          end

          xml.ExchangedDocument do
            xml['ram'].ID id
            xml['ram'].TypeCode '380' # TODO: make configurable
            xml['ram'].IssueDateTime do
              xml['udt'].DateTimeString(format: '102') do
                xml.text(issue_date.strftime("%Y%m%d"))
              end
            end
          end
          xml.SupplyChainTradeTransaction do
            line_items.each_with_index do |item, i|
              item.to_xml(xml, i + 1) # one indexed
            end
            xml['ram'].ApplicableHeaderTradeAgreement do
              xml['ram'].SellerTradeParty do
                seller.to_xml(xml)
              end
              xml['ram'].BuyerTradeParty do
                buyer.to_xml(xml)
              end
            end
            xml['ram'].ApplicableHeaderTradeDelivery do
              xml['ram'].ShipToTradeParty do
                buyer.to_xml(xml, exclude_tax: true)
              end
              xml['ram'].ActualDeliverySupplyChainEvent do
                xml['ram'].OccurrenceDateTime do
                  xml['udt'].DateTimeString(format: '102') do
                    xml.text(issue_date.strftime("%Y%m%d"))
                  end
                end
              end
            end
            xml['ram'].ApplicableHeaderTradeSettlement do
              xml['ram'].InvoiceCurrencyCode currency_code
              xml['ram'].SpecifiedTradeSettlementPaymentMeans do
                xml['ram'].TypeCode payment_code
                xml['ram'].Information payment_text
              end
              xml['ram'].ApplicableTradeTax do
                xml['ram'].CalculatedAmount tax_amount
                xml['ram'].TypeCode 'VAT'
                if tax_reason_text && tax_reason_text != ''
                  xml['ram'].ExemptionReason tax_reason
                end
                xml['ram'].BasisAmount basis_amount
                xml['ram'].CategoryCode tax_category_code
                xml['ram'].RateApplicablePercent tax_percent
              end
              xml['ram'].SpecifiedTradePaymentTerms do
                xml['ram'].Description "Paid"
              end
              xml['ram'].SpecifiedTradeSettlementHeaderMonetarySummation do
                xml['ram'].LineTotalAmount basis_amount
                xml['ram'].TaxBasisTotalAmount basis_amount
                xml['ram'].TaxTotalAmount(currencyID: currency_code) do
                  xml.text(tax_amount)
                end
                xml['ram'].GrandTotalAmount grand_total_amount
                xml['ram'].TotalPrepaidAmount paid_amount
                xml['ram'].DuePayableAmount due_amount
              end
            end
          end
        end
      end
      builder.to_xml
    end
  end

end
