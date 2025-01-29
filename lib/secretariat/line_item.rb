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



require 'bigdecimal'
module Secretariat


  LineItem = Struct.new('LineItem',
    :name,
    :quantity,
    :unit,
    :gross_amount,
    :net_amount,
    :tax_category,
    :tax_percent,
    :tax_amount,
    :discount_amount,
    :discount_reason,
    :charge_amount,
    :origin_country_code,
    :currency_code,
    keyword_init: true
  ) do

    include Versioner

    def errors
      @errors
    end

    def valid?
      @errors = []
      net_price = BigDecimal(net_amount)
      gross_price = BigDecimal(gross_amount)
      charge_price = BigDecimal(charge_amount)
      tax = BigDecimal(tax_amount)
      unit_price = net_price * BigDecimal(quantity.abs)

      if charge_price != unit_price
        @errors << "charge price and gross price times quantity deviate: #{charge_price} / #{unit_price}"
        return false
      end
      if discount_amount
        discount = BigDecimal(discount_amount)
        calculated_net_price = (gross_price - discount).round(2, :down)
        if calculated_net_price != net_price
          @errors = "Calculated net price and net price deviate: #{calculated_net_price} / #{net_price}"
          return false
        end
      end

      calculated_tax = charge_price * BigDecimal(tax_percent) / BigDecimal(100)
      calculated_tax = calculated_tax.round(2)
      calculated_tax = -calculated_tax if quantity.negative?
      if calculated_tax != tax
        @errors << "Tax and calculated tax deviate: #{tax} / #{calculated_tax}"
        return false
      end
      return true
    end

    def unit_code
      UNIT_CODES[unit] || 'C62'
    end

    def tax_category_code(version: 2)
      if version == 1
        return TAX_CATEGORY_CODES_1[tax_category] || 'S'
      end
      TAX_CATEGORY_CODES[tax_category] || 'S'
    end

    def to_xml(xml, line_item_index, version: 2, validate: true)
      if net_amount&.zero?
        self.tax_percent = 0
      end
      if net_amount&.negative?
        # Zugferd doesn't allow negative amounts at the item level.
        # Instead, a negative quantity is used.
        self.quantity = -quantity
        self.gross_amount = gross_amount&.abs
        self.net_amount = net_amount&.abs
        self.charge_amount = charge_amount&.abs
      end
      if validate && !valid?
        pp errors
        raise ValidationError.new("LineItem #{line_item_index} is invalid", errors)
      end

      xml['ram'].IncludedSupplyChainTradeLineItem do
        xml['ram'].AssociatedDocumentLineDocument do
          xml['ram'].LineID line_item_index
        end
        if (version == 2)
          xml['ram'].SpecifiedTradeProduct do
            xml['ram'].Name name
            xml['ram'].OriginTradeCountry do
              xml['ram'].ID origin_country_code
            end
          end
        end
        agreement = by_version(version, 'SpecifiedSupplyChainTradeAgreement', 'SpecifiedLineTradeAgreement')

        xml['ram'].send(agreement) do
          xml['ram'].GrossPriceProductTradePrice do
            Helpers.currency_element(xml, 'ram', 'ChargeAmount', gross_amount, currency_code, add_currency: version == 1, digits: 4)
            if version == 2 && discount_amount
              xml['ram'].BasisQuantity(unitCode: unit_code) do
                xml.text(Helpers.format(quantity, digits: 4))
              end
              xml['ram'].AppliedTradeAllowanceCharge do
                xml['ram'].ChargeIndicator do
                  xml['udt'].Indicator 'false'
                end
                Helpers.currency_element(xml, 'ram', 'ActualAmount', discount_amount, currency_code, add_currency: version == 1)
                xml['ram'].Reason discount_reason
              end
            end
            if version == 1 && discount_amount
              xml['ram'].AppliedTradeAllowanceCharge do
                xml['ram'].ChargeIndicator do
                  xml['udt'].Indicator 'false'
                end
                Helpers.currency_element(xml, 'ram', 'ActualAmount', discount_amount, currency_code, add_currency: version == 1)
                xml['ram'].Reason discount_reason
              end
            end
          end
          xml['ram'].NetPriceProductTradePrice do
            Helpers.currency_element(xml, 'ram', 'ChargeAmount', net_amount, currency_code, add_currency: version == 1, digits: 4)
            if version == 2
              xml['ram'].BasisQuantity(unitCode: unit_code) do
                xml.text(Helpers.format(quantity, digits: 4))
              end
            end
          end
        end

        delivery = by_version(version, 'SpecifiedSupplyChainTradeDelivery', 'SpecifiedLineTradeDelivery')

        xml['ram'].send(delivery) do
          xml['ram'].BilledQuantity(unitCode: unit_code) do
            xml.text(Helpers.format(quantity, digits: 4))
          end
        end

        settlement = by_version(version, 'SpecifiedSupplyChainTradeSettlement', 'SpecifiedLineTradeSettlement')

        xml['ram'].send(settlement) do
          xml['ram'].ApplicableTradeTax do
            xml['ram'].TypeCode 'VAT'
            xml['ram'].CategoryCode tax_category_code(version: version)

            percent = by_version(version, 'ApplicablePercent', 'RateApplicablePercent')
            xml['ram'].send(percent,Helpers.format(tax_percent))

          end
          monetary_summation = by_version(version, 'SpecifiedTradeSettlementMonetarySummation', 'SpecifiedTradeSettlementLineMonetarySummation')
          xml['ram'].send(monetary_summation) do
            Helpers.currency_element(xml, 'ram', 'LineTotalAmount', (quantity.negative? ? -charge_amount  : charge_amount), currency_code, add_currency: version == 1)
          end
        end

        if version == 1
          xml['ram'].SpecifiedTradeProduct do
            xml['ram'].Name name
          end
        end
      end
    end
  end
end
