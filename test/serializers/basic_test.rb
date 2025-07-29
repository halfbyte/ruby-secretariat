require 'test_helper'
require 'date'

module Secretariat
  module Serializers
    class BasicTest < Minitest::Test

      def make_basic_invoice
        invoice = ::Secretariat::Invoice.new(
          id: '471102',
          issue_date: Date.new(2024, 11, 15),
          service_period_start: Date.today,
          service_period_end: Date.today + 30,
          currency_code: 'USD',
          payment_type: :CREDITCARD,
          payment_text: 'Kreditkarte',
          tax_amount: 0,
          basis_amount: BigDecimal('29'),
          grand_total_amount: BigDecimal('29'),
          due_amount: 0,
          paid_amount: 29,
          payment_due_date: Date.today + 14,
          notes: [
            "Rechnung gemäß Bestellung vom 01.11.2024.",
            "Lieferant GmbH
Lieferantenstraße 20
80333 München
Deutschland
Geschäftsführer: Hans Muster
Handelsregisternummer: H A 123
      ",
            "Unsere GLN: 4000001123452
Ihre GLN: 4000001987658
Ihre Kundennummer: GE2020211


Zahlbar innerhalb 30 Tagen netto bis 25.12.2024, 3% Skonto innerhalb 10 Tagen bis 25.11.2024.
      "
          ]
        )
      end

      def test_basic_profile
        ser = Basic.new(make_basic_invoice)
        xml  = ser.serialize
        File.write("debug.xml", xml)
        assert_equal_xml(read_fixture("factur-x-BASIC/factur-x.xml"), xml)
      end
    end
  end
end

