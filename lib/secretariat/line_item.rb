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
    :billed_quantity,
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
    :service_period_start, # if start present start & end are required
    :service_period_end, # end has to be on or after start (secretariat does not validate this)
    :basis_quantity,
    keyword_init: true
  ) do

    include Versioner

    def initialize(**kwargs)
      if kwargs.key?(:quantity) && !kwargs.key?(:billed_quantity)
        kwargs[:billed_quantity] = kwargs.delete(:quantity)
      end
      super(**kwargs)
    end

    def quantity
      warn_once_quantity
      billed_quantity
    end

    def quantity=(val)
      warn_once_quantity
      self.billed_quantity = val
    end

    def warn_once_quantity
      unless @__warned_quantity
        Kernel.warn("[secretariat] LineItem#quantity is deprecated; use #billed_quantity")
        @__warned_quantity = true
      end
    end

    def errors
      @errors
    end

    def valid?
      @errors = []
      net_price = BigDecimal(net_amount)
      gross_price = BigDecimal(gross_amount)
      charge_price = BigDecimal(charge_amount)
      tax = BigDecimal(tax_amount)
      unit_price = net_price * BigDecimal(billed_quantity.abs)

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
      if tax_category != :UNTAXEDSERVICE
        self.tax_percent ||= BigDecimal(0)
        calculated_tax = charge_price * BigDecimal(tax_percent) / BigDecimal(100)
        calculated_tax = calculated_tax.round(2)
        calculated_tax = -calculated_tax if billed_quantity.negative?
        if calculated_tax != tax
          @errors << "Tax and calculated tax deviate: #{tax} / #{calculated_tax}"
          return false
        end
      end
      return true
    end

    def unit_code
      UNIT_CODES[unit] || 'C62'
    end

    # If not provided, BasisQuantity should be 1.0 (price per 1 unit)
    def effective_basis_quantity
      q = basis_quantity.nil? ? BigDecimal("1.0") : BigDecimal(basis_quantity.to_s)
      raise ArgumentError, "basis_quantity must be > 0" if q <= 0
      q
    end

    def tax_category_code(version: 2)
      if version == 1
        return TAX_CATEGORY_CODES_1[tax_category] || 'S'
      end
      TAX_CATEGORY_CODES[tax_category] || 'S'
    end

    def untaxable?
      tax_category == :UNTAXEDSERVICE
    end

    def to_xml(xml, line_item_index, version: 2, validate: true)
      net_price = net_amount && BigDecimal(net_amount)
      gross_price = gross_amount && BigDecimal(gross_amount)
      charge_price = charge_amount && BigDecimal(charge_amount)

      self.tax_percent ||= BigDecimal(0)

      if net_price&.zero?
        self.tax_percent = 0
      end
      
      if net_price&.negative?
        # Zugferd doesn't allow negative amounts at the item level.
        # Instead, a negative quantity is used.
        self.billed_quantity = -billed_quantity
        self.gross_amount = gross_price&.abs
        self.net_amount = net_price&.abs
        self.charge_amount = charge_price&.abs
      end

      if validate && !valid?
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
                xml.text(Helpers.format(effective_basis_quantity, digits: 4))
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
                xml.text(Helpers.format(effective_basis_quantity, digits: 4))
              end
            end
          end
        end

        delivery = by_version(version, 'SpecifiedSupplyChainTradeDelivery', 'SpecifiedLineTradeDelivery')

        xml['ram'].send(delivery) do
          xml['ram'].BilledQuantity(unitCode: unit_code) do
            xml.text(Helpers.format(billed_quantity, digits: 4))
          end
        end

        settlement = by_version(version, 'SpecifiedSupplyChainTradeSettlement', 'SpecifiedLineTradeSettlement')

        xml['ram'].send(settlement) do
          xml['ram'].ApplicableTradeTax do
            xml['ram'].TypeCode 'VAT'
            xml['ram'].CategoryCode tax_category_code(version: version)
            unless untaxable?
              percent = by_version(version, 'ApplicablePercent', 'RateApplicablePercent')
              xml['ram'].send(percent,Helpers.format(tax_percent))            
            end
          end

          if version == 2 && self.service_period_start && self.service_period_end
            xml['ram'].BillingSpecifiedPeriod do
              xml['ram'].StartDateTime do
                xml['udt'].DateTimeString(format: '102') do
                  xml.text(service_period_start.strftime("%Y%m%d"))
                end
              end
              xml['ram'].EndDateTime do
                xml['udt'].DateTimeString(format: '102') do
                  xml.text(service_period_end.strftime("%Y%m%d"))
                end
              end
            end
          end

          monetary_summation = by_version(version, 'SpecifiedTradeSettlementMonetarySummation', 'SpecifiedTradeSettlementLineMonetarySummation')
          xml['ram'].send(monetary_summation) do
            Helpers.currency_element(xml, 'ram', 'LineTotalAmount', (billed_quantity.negative? ? -charge_amount  : charge_amount), currency_code, add_currency: version == 1)
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
