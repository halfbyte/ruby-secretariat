# Changelog

## 3.6.0

- [FEATURE] Add ability to add notes. PR by @corny
- [CHORE] Loosen mime-types dependency requirement. PR  by @corny

## 3.5.0

- [FEATURE] Yet another tax calculation/validation mode :ITEM_BASED. PR by @SubandiK
- [CHORE] Update ruby version files to 3.4.2

## 3.4.0

- [FEATURE] Allow for "untaxable" invoices. This is, for example the case when you deliver services to US states that don't tax these, or if you're falling below the registration threshold.
- [FEATURE] To support valid "untaxable" invoices, `:tax_id`, `:global_id` and `:global_id_scheme_id` are introduced on `TradeParty` as attributes. ZUGFeRD does not allow VAT ids on invoices that are untaxable, so you need a global id (and other validators want you to add the local tax id as well, but that's mandatory, I think). This could be a SWIFT id, for example, which would be an IBAN for EU folks. (IANAL!)
- [FEATURE] Introduce tax_calculation_method = :NONE, which skips collecting taxes from line items and just uses the global values. It also skips some of the validations. This is a hack-ish solution to a problem I ran into where the invoicing service calculated the VAT and net amounts backwards from a round gross amount, resulting in rounding errors when trying to calculate them the correct way round. This is easier to use when you only have one tax rate and all the values are already known.

## 3.3.0

- [FEATURE] Allow for vertical tax calculation. PR by @RST-J
- [FEATURE] Allow for negative line items. PR by @SubandiK
- [FEATURE] Allow for attachments. PR by @mnin
- [FEATURE] Add a few tax exemption reasons that were missing

## 3.2.0

- [CHORE] Update schemas for latest Factur-X version (1.07.2) by @zealot128
- [FEATURE] Allow for multiple tax rates in line items and correctly summarising them in invoice. PR by @SubandiK
- [CHORE] Update copyright notices and add CONTRIBUTORS.md to reflect that this isn't a solo project anymore.

## 3.1.0

- [BUGFIX] Schematron Validator always reported valid. Fix by @SubandiK
- [FEATURE] Allow skipping validations on `Invoice` and `LineItem` to allow for alternative calculation methods. PR by @zealot128
- [FEATURE] Multiple fields added (`payment_due_date`, `service_period_to` + `...from`, `payment_iban`, `buyer_reference`, `payment_terms_text`) to Invoice. PR by @zealot128
- [FEATURE] Return a list of exceptions from schematron validator to make it behave the same as schema validator.

## 3.0.1

- [BUGFIX] Schema JAR must be properly relatively addressed when published as a gem
- [BUGFIX] Make sure tmpdir lib is loaded when needed

## 3.0.0

- [BREAKING] This now needs Java installed to run the Schematron validator, as nokogiri-schematron does not work with XSLT based schematron files
- [BREAKING] For ZUGFeRD 2.x, this library now exclusively uses the schemas for 2.3, or rather Factur-X 1.0.0.7 as it is called. The XML generation part is unchanged, though, as we had no validation issues after upgrading the schemas.

## 2.0.0

- [BREAKING] Validators and XML generators now need a version to use to be able to support ZUGFeRD 1.0

