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


  LineItem = Struct.new('LineItem',
    :name,
    :quantity,
    :unit,
    :unit_amount,
    :charge_amount,
    :tax_category,
    :tax_percent,
    :tax_amount,
    :origin_country_code,
    keyword_init: true
  ) do

    def errors
      @errors
    end

    def valid?
      @errors = []
      unit_price = BigDecimal(unit_amount)
      charge_price = BigDecimal(charge_amount)
      tax = BigDecimal(tax_amount)

      if charge_price != unit_price * BigDecimal(quantity)
        @errors << "charge price and unit price times quantity deviate"
        return false
      end

      calculated_tax = charge_price * BigDecimal(tax_percent) / BigDecimal(100)
      if calculated_tax != tax
        @errors << "Tax and calculated tax deviate"
        return false
      end
      return true
    end

    def unit_code
      UNIT_CODES[unit] || 'C62'
    end

    def tax_category_code
      TAX_CATEGORY_CODES[tax_category] || 'S'
    end

    def to_xml(xml, line_item_index)
      if !valid?
        raise ValidationError.new("LineItem #{line_item_index} is invalid", errors)
      end

      xml['ram'].IncludedSupplyChainTradeLineItem do
        xml['ram'].AssociatedDocumentLineDocument do
          xml['ram'].LineID line_item_index
        end
        xml['ram'].SpecifiedTradeProduct do
          xml['ram'].Name name
          xml['ram'].OriginTradeCountry do
            xml['ram'].ID origin_country_code
          end
        end
        xml['ram'].SpecifiedLineTradeAgreement do
          xml['ram'].GrossPriceProductTradePrice do
            xml['ram'].ChargeAmount unit_amount
            xml['ram'].BasisQuantity(unitCode: unit_code) do
              xml.text(quantity)
            end
          end
          xml['ram'].NetPriceProductTradePrice do
            xml['ram'].ChargeAmount unit_amount
            xml['ram'].BasisQuantity(unitCode: unit_code) do
              xml.text(quantity)
            end
          end
        end
        xml['ram'].SpecifiedLineTradeDelivery do
          xml['ram'].BilledQuantity(unitCode: unit_code) do
            xml.text(quantity)
          end
        end
        xml['ram'].SpecifiedLineTradeSettlement do
          xml['ram'].ApplicableTradeTax do
            xml['ram'].TypeCode 'VAT'
            xml['ram'].CategoryCode tax_category_code
            xml['ram'].RateApplicablePercent tax_percent

          end
          xml['ram'].SpecifiedTradeSettlementLineMonetarySummation do
            xml['ram'].LineTotalAmount charge_amount
          end
        end
      end
    end
  end
end
