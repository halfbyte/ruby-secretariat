require 'test_helper'
require 'date'

module Secretariat
  module Serializers
    class BasicTest < Minitest::Test

      def make_basic_invoice
        invoice = ::Secretariat::Invoice.new(
          id: '12345',
          issue_date: Date.today,
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
          payment_due_date: Date.today + 14
        )
      end



      def test_basic_profile
        ser = Basic.new(make_basic_invoice)
        xml  = ser.serialize
        puts xml

      end
    end
  end
end

