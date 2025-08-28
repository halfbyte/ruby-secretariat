require "test_helper"
require "date"

module Secretariat
  module Serializers
    class BasicTest < Minitest::Test
      def make_basic_invoice
        ::Secretariat::Invoice.new(
          id: "471102",
          issue_date: Date.new(2020, 0o3, 0o5),
          service_period_start: Date.today,
          service_period_end: Date.today + 30,
          currency_code: "USD",
          payment_type: :CREDITCARD,
          payment_text: "Kreditkarte",
          tax_amount: 0,
          basis_amount: BigDecimal(29),
          grand_total_amount: BigDecimal(29),
          due_amount: 0,
          paid_amount: 29,
          payment_due_date: Date.today + 14,
          notes: [
            "Rechnung gemäß Bestellung vom 01.03.2020.",
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


Zahlbar innerhalb 30 Tagen netto bis 04.04.2020, 3% Skonto innerhalb 10 Tagen bis 15.03.2020.
      "
          ],
          line_items: [::Secretariat::LineItem.new(
            name: "GTIN: 4012345001235
Unsere Art.-Nr.: TB100A4
Trennblätter A4
        ",
            quantity: 20.00,
            unit: "H87",
            gross_amount: 9.99,
            tax_category: "S",
            tax_percent: 19,
            charge_amount: 198.00,
            global_id: "4012345001235",
            global_id_scheme_id: "0160"
          )]
        )
      end

      def test_basic_profile
        ser = Basic.new(make_basic_invoice)
        xml = ser.serialize
        File.write("debug.xml", xml)
        assert_equal_xml(read_fixture("BASIC_Einfach.xml"), xml)
      end
    end
  end
end
