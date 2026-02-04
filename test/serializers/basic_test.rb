require "test_helper"
require "date"

module Secretariat
  module Serializers
    class BasicTest < Minitest::Test
      def make_basic_invoice
        ::Secretariat::Invoice.new(
          id: "471102",
          issue_date: Date.new(2020, 3, 5),
          currency_code: "EUR",
          payment_type: :CREDITCARD,
          payment_text: "Kreditkarte",
          tax_amount: BigDecimal("37.62", 10),
          basis_amount: BigDecimal(198),
          grand_total_amount: BigDecimal("235.62", 10),
          due_amount: BigDecimal("235.62", 10),
          paid_amount: 0,
          payment_due_date: Date.new(2020, 4, 4),
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
            billed_quantity: 20.00,
            unit: :PIECE,
            net_amount: 9.90,
            tax_category: "S",
            tax_percent: 19.00,
            tax_amount: 37.62,
            charge_amount: 198.00,
            global_id: "4012345001235",
            global_id_scheme_id: "0160"
          )],
          buyer: ::Secretariat::TradeParty.new({
            name: "Kunden AG Mitte",
            street1: "Hans Muster",
            street2: "Kundenstraße 15",
            city: "Frankfurt",
            postal_code: "69876",
            country_id: "DE"
          }),
          seller: ::Secretariat::TradeParty.new({
            name: "Lieferant GmbH",
            street1: "Lieferantenstraße 20",
            city: "München",
            postal_code: "80333",
            country_id: "DE",
            vat_id: "DE123456789",
            tax_id: "201/113/40209"
          })
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
