require 'test_helper'
require 'date'
require 'base64'

module Secretariat
  class InvoiceTest < Minitest::Test

    def make_eu_invoice(tax_category: :REVERSECHARGE, ship_to: nil)
      seller = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'DE',
        vat_id: 'DE304755032'
      )
      buyer = TradeParty.new(
        id: 'Kunde 4711',
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'SE',
        vat_id: 'SE304755032'
      )
      line_item = LineItem.new(
        name: 'Depfu Starter Plan',
        quantity: 1,
        gross_amount: BigDecimal('29'),
        net_amount: BigDecimal('29'),
        unit: :PIECE,
        charge_amount: BigDecimal('29'),
        tax_category: tax_category,
        tax_percent: 0,
        tax_amount: 0,
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      Invoice.new(
        id: '12345',
        issue_date: Date.today,
        service_period_start: Date.today,
        service_period_end: Date.today + 30,
        seller: seller,
        buyer: buyer,
        ship_to: ship_to,
        line_items: [line_item],
        currency_code: 'USD',
        payment_type: :CREDITCARD,
        payment_text: 'Kreditkarte',
        tax_category: tax_category,
        tax_amount: 0,
        basis_amount: BigDecimal('29'),
        grand_total_amount: BigDecimal('29'),
        due_amount: 0,
        paid_amount: 29,
        payment_due_date: Date.today + 14,
        notes: "This is a test invoice",
        subject_code: 'REG' # BT-21
      )
    end

    def make_eu_invoice_with_line_item_billing_period(tax_category: :REVERSECHARGE)
      seller = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'DE',
        vat_id: 'DE304755032'
      )
      buyer = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'SE',
        vat_id: 'SE304755032'
      )
      line_item = LineItem.new(
        name: 'Depfu Premium Plan',
        quantity: 1,
        gross_amount: BigDecimal('29'),
        net_amount: BigDecimal('29'),
        unit: :YEAR,
        charge_amount: BigDecimal('29'),
        tax_category: tax_category,
        tax_percent: 0,
        tax_amount: 0,
        origin_country_code: 'DE',
        currency_code: 'EUR',
        service_period_start: Date.today,
        service_period_end: Date.today + 364,
      )
      Invoice.new(
        id: '12345',
        issue_date: Date.today,
        # service_period on line_item. removed here to simplify testing of BillingSpecifiedPeriod presence
        # service_period_start: Date.today,
        # service_period_end: Date.today + 30,
        seller: seller,
        buyer: buyer,
        line_items: [line_item],
        currency_code: 'USD',
        payment_type: :CREDITCARD,
        payment_text: 'Kreditkarte',
        tax_category: tax_category,
        tax_amount: 0,
        basis_amount: BigDecimal('29'),
        grand_total_amount: BigDecimal('29'),
        due_amount: 0,
        paid_amount: 29,
        payment_due_date: Date.today + 14,
        notes: "This is a test invoice",
        subject_code: 'REG' # BT-21
      )
    end

    def make_eu_invoice_with_sepa_direct_debit(tax_category: :REVERSECHARGE)
      seller = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'DE',
        vat_id: 'DE304755032'
      )
      buyer = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'SE',
        vat_id: 'SE304755032'
      )
      line_item = LineItem.new(
        name: 'Depfu Premium Plan',
        quantity: 1,
        gross_amount: BigDecimal('29'),
        net_amount: BigDecimal('29'),
        unit: :YEAR,
        charge_amount: BigDecimal('29'),
        tax_category: tax_category,
        tax_percent: 0,
        tax_amount: 0,
        origin_country_code: 'DE',
        currency_code: 'EUR',
        service_period_start: Date.today,
        service_period_end: Date.today + 364,
      )
      Invoice.new(
        id: '12345',
        issue_date: Date.today,
        # service_period on line_item. removed here to simplify testing of BillingSpecifiedPeriod presence
        # service_period_start: Date.today,
        # service_period_end: Date.today + 30,
        seller: seller,
        buyer: buyer,
        line_items: [line_item],
        currency_code: 'USD',
        payment_type: :CREDITCARD,
        payment_text: 'Kreditkarte',
        tax_category: tax_category,
        tax_amount: 0,
        basis_amount: BigDecimal('29'),
        grand_total_amount: BigDecimal('29'),
        due_amount: 0,
        paid_amount: 29,
        payment_due_date: Date.today + 14,
        notes: "This is a test invoice",
        direct_debit_mandate_reference_id: "MANDATE REFERENCE", # BT-89
        direct_debit_creditor_id: "DE98ZZZ09999999999", # BT-90
        direct_debit_iban: "DE02120300000000202051", # BT-91
        subject_code: 'REG' # BT-21

      )
    end

    def make_foreign_invoice(tax_category: :TAXEXEMPT)
      seller = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'DE',
      )
      buyer = TradeParty.new(
        name: 'Another Corp Inc.',
        street1: 'Example Street 12',
        city: 'Hamburg',
        postal_code: 'NH-2003',
        country_id: 'US',
      )
      line_item = LineItem.new(
        name: 'Depfu Starter Plan',
        quantity: 1,
        gross_amount: BigDecimal('29'),
        net_amount: BigDecimal('29'),
        unit: :PIECE,
        charge_amount: BigDecimal('29'),
        tax_category: tax_category,
        tax_percent: 0,
        tax_amount: 0,
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      Invoice.new(
        id: '12345',
        issue_date: Date.today,
        service_period_start: Date.today,
        service_period_end: Date.today + 30,
        seller: seller,
        buyer: buyer,
        line_items: [line_item],
        currency_code: 'USD',
        payment_type: :CREDITCARD,
        payment_text: 'Kreditkarte',
        tax_category: tax_category,
        tax_amount: 0,
        basis_amount: BigDecimal('29'),
        grand_total_amount: BigDecimal('29'),
        due_amount: 0,
        paid_amount: 29,
        payment_due_date: Date.today + 14,
        subject_code: 'REG' # BT-21
      )
    end

    def make_eu_invoice_with_attachment
      seller = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'DE',
        vat_id: 'DE304755032'
      )
      buyer = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'SE',
        vat_id: 'SE304755032'
      )
      line_item = LineItem.new(
        name: 'Depfu Starter Plan',
        quantity: 1,
        gross_amount: '29',
        net_amount: '29',
        unit: :PIECE,
        charge_amount: '29',
        tax_category: :REVERSECHARGE,
        tax_percent: 0,
        tax_amount: "0",
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      attachment = Attachment.new(
        filename: 'example.pdf',
        type_code: 916,
        base64: Base64.encode64(open(File.join(__dir__, 'fixtures/example.pdf')).read)
      )
      Invoice.new(
        id: '12345',
        issue_date: Date.today,
        service_period_start: Date.today,
        service_period_end: Date.today + 30,
        seller: seller,
        buyer: buyer,
        line_items: [line_item],
        currency_code: 'USD',
        payment_type: :CREDITCARD,
        payment_text: 'Kreditkarte',
        tax_category: :REVERSECHARGE,
        tax_amount: '0',
        basis_amount: '29',
        grand_total_amount: 29,
        due_amount: 0,
        paid_amount: 29,
        payment_due_date: Date.today + 14,
        attachments: [attachment],
        subject_code: 'REG' # BT-21
      )
    end

    def make_de_invoice
      seller = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'DE',
        vat_id: 'DE304755032'
      )
      buyer = TradeParty.new(
        name: 'Depfu inc',
        person_name: 'Max Mustermann',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'DE',
        vat_id: 'DE304755032'
      )
      line_item = LineItem.new(
        name: 'Depfu Starter Plan',
        quantity: 1,
        unit: :PIECE,
        gross_amount: BigDecimal('29'),
        net_amount: BigDecimal('20'),
        charge_amount: BigDecimal('20'),
        discount_amount: BigDecimal('9'),
        discount_reason: 'Rabatt',
        tax_category: :STANDARDRATE,
        tax_percent: '19',
        tax_amount: BigDecimal("3.80"),
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      Invoice.new(
        id: '12345',
        issue_date: Date.today,
        service_period_start: Date.today,
        service_period_end: Date.today + 30,
        seller: seller,
        buyer: buyer,
        buyer_reference: "112233",
        line_items: [line_item],
        currency_code: 'USD',
        payment_type: :CREDITCARD,
        payment_text: 'Kreditkarte',
        payment_reference: 'INV 123123123',
        payment_iban: 'DE02120300000000202051',
        payment_terms_text: "Zahlbar innerhalb von 14 Tagen ohne Abzug",
        tax_category: :STANDARDRATE,
        tax_amount: BigDecimal('3.80'),
        basis_amount: BigDecimal('20'),
        grand_total_amount: BigDecimal('23.80'),
        due_amount: 0,
        paid_amount: BigDecimal('23.80'),
        payment_due_date: Date.today + 14,
        subject_code: 'REG' # BT-21
      )
    end

    def make_de_invoice_with_multiple_tax_rates
      seller = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'DE',
        vat_id: 'DE304755032'
      )
      buyer = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'DE',
        vat_id: 'DE304755032'
      )
      line_item = LineItem.new(
        name: 'Depfu Starter Plan',
        quantity: 2,
        unit: :PIECE,
        gross_amount: BigDecimal('23.80'),
        net_amount: BigDecimal('20'),
        charge_amount: BigDecimal('40'),
        tax_category: :STANDARDRATE,
        tax_percent: '19',
        tax_amount: BigDecimal("7.60"),
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      line_item2 = LineItem.new(
        name: 'Cup of Coffee',
        quantity: 1,
        unit: :PIECE,
        gross_amount: BigDecimal('2.68'),
        net_amount: BigDecimal('2.50'),
        charge_amount: BigDecimal('2.50'),
        tax_category: :STANDARDRATE,
        tax_percent: '7',
        tax_amount: BigDecimal("0.18"),
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      line_item3 = LineItem.new(
        name: 'Returnable Deposit',
        quantity: 1,
        unit: :PIECE,
        gross_amount: BigDecimal('5'),
        net_amount: BigDecimal('5'),
        charge_amount: BigDecimal('5'),
        tax_category: :ZEROTAXPRODUCTS,
        tax_percent: '0',
        tax_amount: BigDecimal("0"),
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      Invoice.new(
        id: '12345',
        issue_date: Date.today,
        service_period_start: Date.today,
        service_period_end: Date.today + 30,
        seller: seller,
        buyer: buyer,
        buyer_reference: "112233",
        line_items: [line_item, line_item2, line_item3],
        currency_code: 'USD',
        payment_type: :CREDITCARD,
        payment_text: 'Kreditkarte',
        payment_iban: 'DE02120300000000202051',
        payment_terms_text: "Zahlbar innerhalb von 14 Tagen ohne Abzug",
        tax_category: :STANDARDRATE,
        tax_amount: BigDecimal('7.78'),
        basis_amount: BigDecimal('47.50'),
        grand_total_amount: BigDecimal('55.28'),
        due_amount: 0,
        paid_amount: BigDecimal('55.28'),
        payment_due_date: Date.today + 14,
        subject_code: 'REG' # BT-21
      )
    end

    def make_negative_de_invoice
      seller = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'DE',
        vat_id: 'DE304755032'
      )
      buyer = TradeParty.new(
        name: 'Depfu inc',
        street1: 'Quickbornstr. 46',
        city: 'Hamburg',
        postal_code: '20253',
        country_id: 'DE',
        vat_id: 'DE304755032'
      )
      line_item = LineItem.new(
        name: 'Depfu Starter Plan',
        quantity: 2,
        unit: :PIECE,
        gross_amount: BigDecimal('-100'),
        net_amount: BigDecimal('-100'),
        charge_amount: BigDecimal('-200'),
        tax_category: :STANDARDRATE,
        tax_percent: '19',
        tax_amount: BigDecimal('-38'),
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      Invoice.new(
        id: '12345',
        issue_date: Date.today,
        service_period_start: Date.today,
        service_period_end: Date.today + 30,
        seller: seller,
        buyer: buyer,
        buyer_reference: "112233",
        line_items: [line_item],
        currency_code: 'USD',
        payment_type: :CREDITCARD,
        payment_text: 'Kreditkarte',
        payment_reference: 'INV 123123123',
        payment_iban: 'DE02120300000000202051',
        payment_terms_text: "Wir zahlen die Gutschrift unmittelbar aus",
        payment_bic: 'BYLADEM1001',
        payment_payee_account_name: 'Depfu inc',
        tax_category: :STANDARDRATE,
        tax_amount: BigDecimal('-38'),
        basis_amount: BigDecimal('-200'),
        grand_total_amount: BigDecimal('-238'),
        due_amount: BigDecimal('-238'),
        paid_amount: 0,
        payment_due_date: Date.today + 14
      )
    end

    def make_fr_invoice
      seller = TradeParty.new(
        name: 'France inc',
        legal_organization: { id: '304755032', scheme_id: '0002' },
        street1: '1 rue de Rivoli',
        city: 'PARIS',
        postal_code: '75001',
        country_id: 'FR',
        vat_id: 'FR304755032'
      )
      buyer = TradeParty.new(
        name: 'France inc',
        person_name: 'Max Mustermann',
        street1: '1 rue de Rivoli',
        city: 'PARIS',
        postal_code: '75001',
        country_id: 'FR',
        vat_id: 'FR304755032'
      )
      line_item = LineItem.new(
        name: 'Depfu Starter Plan',
        quantity: 1,
        unit: :PIECE,
        gross_amount: BigDecimal('29'),
        net_amount: BigDecimal('20'),
        charge_amount: BigDecimal('20'),
        discount_amount: BigDecimal('9'),
        discount_reason: 'Rabatt',
        tax_category: :STANDARDRATE,
        tax_percent: '19',
        tax_amount: BigDecimal("3.80"),
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      Invoice.new(
        id: '12345',
        issue_date: Date.today,
        service_period_start: Date.today,
        service_period_end: Date.today + 30,
        seller: seller,
        buyer: buyer,
        ship_to: false,
        buyer_reference: "112233",
        line_items: [line_item],
        currency_code: 'USD',
        payment_type: :CREDITCARD,
        payment_text: 'Kreditkarte',
        payment_reference: 'INV 123123123',
        payment_iban: 'DE02120300000000202051',
        payment_terms_text: "Zahlbar innerhalb von 14 Tagen ohne Abzug",
        tax_category: :STANDARDRATE,
        tax_amount: BigDecimal('3.80'),
        basis_amount: BigDecimal('20'),
        grand_total_amount: BigDecimal('23.80'),
        due_amount: 0,
        paid_amount: BigDecimal('23.80'),
        payment_due_date: Date.today + 14
      )
    end


    def test_simple_eu_invoice_v2
      begin
        xml = make_eu_invoice.to_xml(version: 2)
      rescue ValidationError => e
        pp e.errors
      end

      assert_match(/<ram:CategoryCode>AE<\/ram:CategoryCode>/, xml)
      assert_match(/<ram:ExemptionReason>Reverse Charge<\/ram:ExemptionReason>/, xml)
      assert_match(/<ram:RateApplicablePercent>/, xml)
      assert_match(%r{<ram:BuyerTradeParty>\s*<ram:ID>Kunde 4711</ram:ID>}, xml)
      refute_match(/<ram:Reason>/, xml)

      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schema
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts error
        end
      end
      assert_equal [], errors
    rescue ValidationError => e
      puts e.errors
    end

    def test_simple_eu_invoice_v2_without_ship_to
      begin
        xml = make_eu_invoice(ship_to: false).to_xml(version: 2)
      rescue ValidationError => e
        pp e.errors
      end

      refute_match(/<ram:ShipToTradeParty>/, xml)

      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schema
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts error
        end
      end
      assert_equal [], errors
    rescue ValidationError => e
      puts e.errors
    end

    def test_simple_eu_invoice_v2_with_line_item_billing_period
      begin
        xml = make_eu_invoice_with_line_item_billing_period.to_xml(version: 2)
        assert_match(/<ram:CategoryCode>AE<\/ram:CategoryCode>/, xml)
        assert_match(/<ram:ExemptionReason>Reverse Charge<\/ram:ExemptionReason>/, xml)
        assert_match(/<ram:RateApplicablePercent>/, xml)
        assert_match(/<ram:BillingSpecifiedPeriod>/, xml)
      rescue ValidationError => e
        pp e.errors
      end
      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schema
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts error
        end
      end
      assert_equal [], errors
    rescue ValidationError => e
      puts e.errors
    end

    def test_simple_eu_invoice_v2_with_sepa_direct_debit
      begin
        xml = make_eu_invoice_with_sepa_direct_debit.to_xml(version: 2)
        assert_match(%r{<ram:CreditorReferenceID>DE98ZZZ09999999999</ram:CreditorReferenceID>}, xml)
        assert_match(%r{<ram:PayerPartyDebtorFinancialAccount>\s*<ram:IBANID>DE02120300000000202051\s*</ram:IBANID>}, xml)
        assert_match(%r{<ram:DirectDebitMandateID>MANDATE REFERENCE</ram:DirectDebitMandateID>}, xml)

      rescue ValidationError => e
        pp e.errors
      end
      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schema
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts error
        end
      end
      assert_equal [], errors
    rescue ValidationError => e
      puts e.errors
    end

    def test_simple_foreign_invoice_v2_taxexpempt
      begin
        xml = make_foreign_invoice(tax_category: :TAXEXEMPT).to_xml(version: 2)
      rescue ValidationError => e
        pp e.errors
      end

      assert_match(/<ram:CategoryCode>E<\/ram:CategoryCode>/, xml)
      assert_match(/<ram:ExemptionReason>VAT exempt<\/ram:ExemptionReason>/, xml)
      assert_match(/<ram:RateApplicablePercent>/, xml)

      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schema
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts error
        end
      end
      assert_equal [], errors
    rescue ValidationError => e
      puts e.errors
    end

    def test_simple_foreign_invoice_v2_untaxed
      begin
        xml = make_foreign_invoice(tax_category: :UNTAXEDSERVICE).to_xml(version: 2)
      rescue ValidationError => e
        pp e.errors
      end

      assert_match(/<ram:CategoryCode>O<\/ram:CategoryCode>/, xml)
      assert_match(/<ram:ExemptionReason>Not subject to VAT<\/ram:ExemptionReason>/, xml)

      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schema
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts error
        end
      end
      assert_equal [], errors
    rescue ValidationError => e
      puts e.errors
    end

    def test_simple_eu_invoice_against_schematron
      xml = make_eu_invoice.to_xml(version: 2)
      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schematron
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts "#{error}"
        end
      end
      assert_equal [], errors
    end

    def test_simple_eu_invoice_with_attachment_against_schematron
      xml = make_eu_invoice_with_attachment.to_xml(version: 2)
      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schematron
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts "#{error}"
        end
      end
      assert_equal [], errors
    end

    def test_simple_de_invoice_v2
      xml = make_de_invoice.to_xml(version: 2)
      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schema
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts error
        end
      end
      assert_equal [], errors
    end

    def test_simple_de_invoice_v1
      xml = make_de_invoice.to_xml(version: 1)
      v = Validator.new(xml, version: 1)
      errors = v.validate_against_schema
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts error
        end
      end
      assert_equal [], errors
    end

    def test_simple_eu_invoice_v1
      begin
        xml = make_eu_invoice.to_xml(version: 1)
      rescue ValidationError => e
        pp e.errors
      end

      v = Validator.new(xml, version: 1)
      errors = v.validate_against_schema
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts error
        end
      end
      assert_equal [], errors
    rescue ValidationError => e
      puts e.errors
    end

    def test_simple_de_invoice_against_schematron
      xml = make_de_invoice.to_xml(version: 1)
      v = Validator.new(xml, version: 1)
      errors = v.validate_against_schematron
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts "#{error[:line]}: #{error[:message]}"
        end
      end
      assert_equal [], errors
    end

    def test_de_multiple_taxes_invoice_v1
      xml = make_de_invoice_with_multiple_tax_rates.to_xml(version: 1)
      v = Validator.new(xml, version: 1)
      errors = v.validate_against_schema
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts error
        end
      end
      assert_equal [], errors
    end

    def test_de_multiple_taxes_invoice_v2
      xml = make_de_invoice_with_multiple_tax_rates.to_xml(version: 2)
      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schema
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts error
        end
      end
      assert_equal [], errors
    end

    def test_de_multiple_taxes_invoice_against_schematron_1
      xml = make_de_invoice_with_multiple_tax_rates.to_xml(version: 1)
      v = Validator.new(xml, version: 1)
      errors = v.validate_against_schematron
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts "#{error[:line]}: #{error[:message]}"
        end
      end
      assert_equal [], errors
    end

    def test_de_multiple_taxes_invoice_against_schematron_2
      xml = make_de_invoice_with_multiple_tax_rates.to_xml(version: 2)
      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schematron
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts "#{error[:line]}: #{error[:message]}"
        end
      end
      assert_equal [], errors
    end

    def test_negative_de_invoice_against_schematron_1
      xml = make_negative_de_invoice.to_xml(version: 1)
      v = Validator.new(xml, version: 1)
      errors = v.validate_against_schematron
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts "#{error[:line]}: #{error[:message]}"
        end
      end
      assert_equal [], errors
    end

    def test_negative_de_invoice_against_schematron_2
      xml = make_negative_de_invoice.to_xml(version: 2)
      v = Validator.new(xml, version: 2)
      errors = v.validate_against_schematron
      if !errors.empty?
        puts xml
        errors.each do |error|
          puts "#{error[:line]}: #{error[:message]}"
        end
      end
      assert_equal [], errors
    end

    def test_invoice_object_extensions
      invoice = make_de_invoice
      xml = invoice.to_xml(version: 2)

      assert_match(/<ram:PaymentReference>#{invoice.payment_reference}<\/ram:PaymentReference>/, xml)
      assert_match(%r{<ram:DefinedTradeContact>\s*<ram:PersonName>Max Mustermann</ram:PersonName>\s*</ram:DefinedTradeContact>}, xml)
      assert_match(/<ram:Reason>/, xml)
    end

    def test_fr_invoice
      invoice = make_fr_invoice
      xml = invoice.to_xml(version: 2)
      assert_match(%r{<ram:SpecifiedLegalOrganization>\s*<ram:ID schemeID="0002">304755032</ram:ID>\s*</ram:SpecifiedLegalOrganization>}, xml)
    end

    # A gross-leading row: the gross price is fixed, net and VAT are derived from
    # it, so the row's VAT (27.21) is one cent below net x rate (27.2153 -> 27.22).
    def make_gross_leading_invoice(line_tax:, invoice_tax:)
      line_item = LineItem.new(
        name: '8 x Overnight stay',
        billed_quantity: BigDecimal('8'),
        unit: :PIECE,
        gross_amount: BigDecimal('52'),
        net_amount: BigDecimal('48.59875'),
        charge_amount: BigDecimal('388.79'),
        tax_category: :STANDARDRATE,
        tax_percent: '7',
        tax_amount: line_tax,
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      invoice = make_de_invoice
      invoice.currency_code = 'EUR'
      invoice.tax_calculation_method = :ITEM_BASED
      invoice.line_items = [line_item]
      invoice.basis_amount = '388.79'
      invoice.tax_amount = invoice_tax
      invoice.grand_total_amount = (BigDecimal('388.79') + BigDecimal(invoice_tax)).to_s('F')
      invoice.due_amount = invoice.grand_total_amount
      invoice.paid_amount = 0
      invoice
    end

    def test_item_based_invoice_keeps_line_vat_rounded_from_the_gross_price
      invoice = make_gross_leading_invoice(line_tax: BigDecimal('27.21'), invoice_tax: '27.21')

      assert invoice.valid?, invoice.errors.inspect
      xml = invoice.to_xml(version: 2)
      assert_match(%r{<ram:CalculatedAmount>27.21</ram:CalculatedAmount>}, xml)
      assert_match(%r{<ram:GrandTotalAmount>416.00</ram:GrandTotalAmount>}, xml)
    end

    def test_line_vat_more_than_a_cent_off_is_still_rejected
      line_item = make_gross_leading_invoice(line_tax: BigDecimal('27.20'), invoice_tax: '27.20').line_items.first

      refute line_item.valid?
      assert_equal ["Tax and calculated tax deviate: 0.272e2 / 0.2722e2"], line_item.errors
    end

    def test_item_based_totals_passed_as_strings_leave_no_errors
      invoice = make_gross_leading_invoice(line_tax: BigDecimal('27.21'), invoice_tax: '27.21')

      assert invoice.valid?
      assert_equal [], invoice.errors
    end

    def test_item_based_invoice_rejects_a_tax_total_that_differs_from_its_lines
      invoice = make_de_invoice
      invoice.tax_calculation_method = :ITEM_BASED
      untaxed = invoice.line_items.first
      untaxed.tax_category = :UNTAXEDSERVICE
      untaxed.tax_percent = nil
      untaxed.tax_amount = BigDecimal('3.80')
      invoice.tax_amount = BigDecimal('0')
      invoice.grand_total_amount = BigDecimal('20')

      refute invoice.valid?
      assert_equal ["Tax amount 0.0 and summed up item tax amounts 3.8 deviate"], invoice.errors
    end

    # Two days, 120 participants, 5,000.00 net per day: the unit price is stored
    # with four decimals (41.6667), so 41.6667 x 120 = 5000.004 while each line
    # total is 5000.00. Summing unit price x quantity drifts to 10000.008 and
    # rounds to 10000.01, a cent off the lines it is made of.
    def test_vat_base_is_the_sum_of_the_line_totals
      line_items = %w[Day1 Day2].map do |day|
        LineItem.new(
          name: "Conference package #{day}",
          billed_quantity: BigDecimal('120'),
          unit: :PIECE,
          gross_amount: BigDecimal('41.6667'),
          net_amount: BigDecimal('41.6667'),
          charge_amount: BigDecimal('5000.00'),
          tax_category: :STANDARDRATE,
          tax_percent: '19',
          tax_amount: BigDecimal('950.00'),
          origin_country_code: 'DE',
          currency_code: 'EUR'
        )
      end
      invoice = make_de_invoice
      invoice.currency_code = 'EUR'
      invoice.tax_calculation_method = :ITEM_BASED
      invoice.line_items = line_items
      invoice.basis_amount = '10000.00'
      invoice.tax_amount = '1900.00'
      invoice.grand_total_amount = '11900.00'
      invoice.due_amount = '11900.00'
      invoice.paid_amount = 0

      assert invoice.valid?, invoice.errors.inspect
      xml = invoice.to_xml(version: 2)
      assert_match(%r{<ram:BasisAmount>10000.00</ram:BasisAmount>}, xml)
    end

    def test_invoice_with_quantity_causing_sub_cent_amounts
      errors = []

      invoice = make_de_invoice
      invoice.tax_calculation_method = :ITEM_BASED
      invoice.line_items.first.net_amount = BigDecimal('10.12')
      invoice.line_items.first.gross_amount = BigDecimal('10.12')
      invoice.line_items.first.discount_amount = BigDecimal('0')
      invoice.line_items.first.billed_quantity = BigDecimal('0.1')
      invoice.line_items.first.charge_amount = BigDecimal('1.01')
      invoice.line_items.first.tax_amount = BigDecimal('0.19')
      invoice.basis_amount = BigDecimal('1.01') # 1.012 rounded
      invoice.tax_amount = BigDecimal('0.19')
      invoice.grand_total_amount = BigDecimal('1.2')

      begin
        invoice.to_xml(version: 2)
      rescue ValidationError => e
        errors = e.errors
        pp e.errors
      end
      assert_equal [], errors
    end
  end
end
