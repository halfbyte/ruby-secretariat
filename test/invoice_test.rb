require 'test_helper'
require 'date'
require 'base64'

module Secretariat
  class InvoiceTest < Minitest::Test

    def make_eu_invoice(tax_category: :REVERSECHARGE)
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
        payment_due_date: Date.today + 14
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
        payment_due_date: Date.today + 14
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
        attachments: [attachment]
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
        payment_due_date: Date.today + 14
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
        payment_due_date: Date.today + 14
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
        tax_category: :STANDARDRATE,
        tax_amount: BigDecimal('-38'),
        basis_amount: BigDecimal('-200'),
        grand_total_amount: BigDecimal('-238'),
        due_amount: BigDecimal('-238'),
        paid_amount: 0,
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
  end
end
