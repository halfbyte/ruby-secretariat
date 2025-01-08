require 'test_helper'
require 'date'

module Secretariat
  class InvoiceTest < Minitest::Test

    def make_eu_invoice
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
        payment_due_date: Date.today + 14
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
        gross_amount: '29',
        net_amount: '20',
        charge_amount: '20',
        discount_amount: '9',
        discount_reason: 'Rabatt',
        tax_category: :STANDARDRATE,
        tax_percent: '19',
        tax_amount: "3.80",
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
        tax_amount: '3.80',
        basis_amount: '20',
        grand_total_amount: '23.80',
        due_amount: 0,
        paid_amount: '23.80',
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
        gross_amount: '23.80',
        net_amount: '20',
        charge_amount: '40',
        tax_category: :STANDARDRATE,
        tax_percent: '19',
        tax_amount: "7.60",
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      line_item2 = LineItem.new(
        name: 'Cup of Coffee',
        quantity: 1,
        unit: :PIECE,
        gross_amount: '2.68',
        net_amount: '2.50',
        charge_amount: '2.50',
        tax_category: :STANDARDRATE,
        tax_percent: '7',
        tax_amount: "0.18",
        origin_country_code: 'DE',
        currency_code: 'EUR'
      )
      line_item3 = LineItem.new(
        name: 'Returnable Deposit',
        quantity: 1,
        unit: :PIECE,
        gross_amount: '5',
        net_amount: '5',
        charge_amount: '5',
        tax_category: :ZEROTAXPRODUCTS,
        tax_percent: '0',
        tax_amount: "0",
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
        tax_amount: '7.78',
        basis_amount: '47.50',
        grand_total_amount: '55.28',
        due_amount: 0,
        paid_amount: '55.28',
        payment_due_date: Date.today + 14
      )
    end

    def test_simple_eu_invoice_v2
      begin
        xml = make_eu_invoice.to_xml(version: 2)
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
  end
end
