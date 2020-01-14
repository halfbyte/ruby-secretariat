module Secretariat
  module Helpers
    def self.format(something, round: nil, digits:2)
      dec = BigDecimal(something, 10)
      dec = dec.round(round, :down) if round
      "%0.#{digits}f" % dec
    end

    def self.currency_element(xml, ns, name, amount, currency, add_currency: true, digits: 2)
      attrs = {}
      if add_currency
        attrs[:currencyID] = currency
      end
      xml[ns].send(name, attrs) do
        xml.text(format(amount, round: 4, digits: digits))
      end
    end
  end
end
